Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareProfile.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ServiceStartup.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Individual-Tweaks.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Windows11-Tweaks.psm1"

function Set-LowRamPagefile {
    [CmdletBinding()]
    param (
        [Double] $RamGB
    )

    $InitialMb = [Math]::Max(4096, [Int][Math]::Round($RamGB * 1024))
    $MaximumMb = [Math]::Max(8192, [Int][Math]::Round($RamGB * 2048))
    $Letter = $env:SystemDrive.TrimEnd('\')
    Write-Status -Types "+", "Memory" -Status "Setting pagefile on $Letter to $InitialMb-$MaximumMb MB for a ${RamGB}GB machine..."
    Try {
        $Cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $Cs | Set-CimInstance -Property @{ AutomaticManagedPagefile = $false }
        $Pf = Get-CimInstance -ClassName Win32_PageFileSetting -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "$Letter*" }
        If ($Pf) {
            $Pf | Set-CimInstance -Property @{ InitialSize = $InitialMb; MaximumSize = $MaximumMb }
        } Else {
            New-CimInstance -ClassName Win32_PageFileSetting -Property @{ Name = "$Letter\pagefile.sys"; InitialSize = $InitialMb; MaximumSize = $MaximumMb } | Out-Null
        }
    } Catch {
        Write-Status -Types "?", "Memory" -Status "Pagefile CIM change failed, applying native registry configuration..." -Warning
        Try {
            Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Type MultiString -Value @("$Letter\pagefile.sys $InitialMb $MaximumMb")
        } Catch {
            Write-Status -Types "?", "Memory" -Status "Could not set a fixed pagefile. Leaving system-managed." -Warning
        }
    }
}

function Restore-SystemManagedPagefile {
    Write-Status -Types "*", "Memory" -Status "Restoring system-managed pagefile..."
    Try {
        $Cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $Cs | Set-CimInstance -Property @{ AutomaticManagedPagefile = $true }
    } Catch {
        Try {
            Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Type MultiString -Value @("?:\pagefile.sys")
        } Catch {
            Write-Status -Types "?", "Memory" -Status "Could not restore system-managed pagefile: $_" -Warning
        }
    }
}

function Optimize-Memory {
    [CmdletBinding()]
    param (
        [Switch] $Revert,
        [Switch] $ForceAggressive
    )

    $TweakType = "Memory"
    Write-Title "Memory, pagefile, CompactOS, Storage Sense"

    If ($Revert) {
        Write-Status -Types "*", $TweakType -Status "Reverting memory / disk footprint tweaks..." -Warning
        Restore-SystemManagedPagefile
        Try { compact.exe /CompactOS:never | Out-Host } Catch { }
        Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWord -Value 0
        return
    }

    $Profile = Get-HardwareProfile
    If ($ForceAggressive -or $env:WIN_DEBLOAT_PROFILE_OVERRIDE -eq 'ExtremeLowEnd') {
        $Profile = Resolve-HardwareProfile -RamGB 4 -CpuCores 2 -DriveType $Profile.DriveType -FreeDiskGB $Profile.FreeDiskGB -IsLaptop $(If ($Profile.IsLaptop) { 1 } Else { 0 }) -OverrideName 'ExtremeLowEnd'
    }

    Write-Status -Types "@", $TweakType -Status $Profile.Summary

    Write-Section "Paging and RAM pressure"
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Type DWord -Value $(If ($Profile.Name -eq 'HighEnd' -and $Profile.DriveType -eq 'SSD') { 1 } Else { 0 })
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Type DWord -Value 0

    If ($Profile.KeepMemoryCompression) {
        Write-Status -Types "+", $TweakType -Status "Keeping Memory Compression ON (critical on 4-8GB PCs)..."
        Try { Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue | Out-Null } Catch { }
    }

    If ($Profile.PagefileStrategy -eq 'FixedLowRam') {
        Set-LowRamPagefile -RamGB $Profile.RamGB
    } Else {
        Restore-SystemManagedPagefile
    }

    Write-Section "Superfetch / SysMain / Search"
    If ($Profile.DisableSysMain) {
        Write-Status -Types "-", $TweakType -Status "Disabling SysMain (Superfetch) — it fights games/apps for RAM on this profile..."
        Set-ServiceStartup -State 'Disabled' -Services @("SysMain")
        Try { Stop-Service "SysMain" -Force -ErrorAction SilentlyContinue } Catch { }
    }

    If ($Profile.DisableSearch) {
        Write-Status -Types "-", $TweakType -Status "Disabling Windows Search indexing (huge disk/RAM win on HDD and 8GB)..."
        Disable-WindowsSearch
    }

    Write-Section "Disk footprint"
    Enable-StorageSenseLowEnd
    Write-Status -Types "-", $TweakType -Status "Disabling Reserved Storage if the SKU allows it..."
    Try { DISM /Online /Set-ReservedStorageState /State:Disabled | Out-Host } Catch { }

    If ($Profile.UseCompactOS) {
        Write-Status -Types "+", $TweakType -Status "Enabling CompactOS (OS files compressed — best on tiny disks)..."
        Try { compact.exe /CompactOS:always | Out-Host } Catch {
            Write-Status -Types "?", $TweakType -Status "CompactOS failed: $_" -Warning
        }
    }

    If ($Profile.DisableHibernate) {
        Write-Status -Types "-", $TweakType -Status "Disabling Hibernate to delete hiberfil.sys (desktop + low disk)..."
        Disable-Hibernate
        Disable-FastStartup
    } ElseIf (-not $Profile.IsLaptop -and $Profile.IsConstrained) {
        Disable-FastStartup
    }

    Write-Section "NTFS chatter"
    Write-Status -Types "+", $TweakType -Status "Disabling NTFS last-access timestamps..."
    Try { fsutil behavior set disablelastaccess 1 | Out-Host } Catch { }

    Write-Status -Types "+", $TweakType -Status "Memory pass complete for profile $($Profile.Name)."
}

$Force = ($env:WIN_DEBLOAT_FORCE_AGGRESSIVE -eq '1')
If ($Revert -or $Global:Revert) {
    Optimize-Memory -Revert
} ElseIf ($Force) {
    Optimize-Memory -ForceAggressive
} Else {
    Optimize-Memory
}
