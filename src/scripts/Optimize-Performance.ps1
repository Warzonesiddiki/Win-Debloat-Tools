Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Open-File.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareInfo.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareProfile.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Unregister-DuplicatedPowerPlan.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Individual-Tweaks.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Windows11-Tweaks.psm1"

# Advanced Windows 10/11 Performance, Responsiveness & Latency Optimizer

function Optimize-Performance() {
    [CmdletBinding()]
    param(
        [Switch] $Revert,
        [Int]    $Zero = 0,
        [Int]    $One = 1,
        [Array]  $EnableStatus = @(
            @{ Symbol = "-"; Status = "Disabling"; }
            @{ Symbol = "+"; Status = "Enabling"; }
        )
    )
    $TweakType = "Performance"

    If (($Revert)) {
        Write-Status -Types "*", $TweakType -Status "Reverting the tweaks is set to '$Revert'." -Warning
        $Zero = 1
        $One = 0
        $EnableStatus = @(
            @{ Symbol = "*"; Status = "Restoring"; }
            @{ Symbol = "*"; Status = "Re-Disabling"; }
        )
    }

    $PCSystemType = Get-PCSystemType
    $HardwareProfile = Get-HardwareProfile
    # Initialize all Path variables used to Registry Tweaks
    $PathToLMMultimediaSystemProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $PathToLMMultimediaSystemProfileOnGameTasks = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    $PathToLMPoliciesEdge = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    $PathToLMPoliciesPsched = "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
    $PathToLMPoliciesWindowsStore = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $PathToUsersControlPanelDesktop = "Registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop"
    $PathToCUControlPanelDesktop = "HKCU:\Control Panel\Desktop"
    $PathToCUGameBar = "HKCU:\SOFTWARE\Microsoft\GameBar"

    Write-Title "Performance & Latency Tweaks"

    Write-Section "System & Graphics"
    Write-Caption "Display"
    If ($HardwareProfile.EnableHAGS -and -not $Revert) {
        Write-Status -Types "+", $TweakType, "20H1" -Status "Enable Hardware Accelerated GPU Scheduling... (Windows 10+ - Needs Restart)"
        Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2
    } ElseIf ($Revert) {
        Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 1
    } Else {
        Write-Status -Types "@", $TweakType -Status "Skipping HAGS on $($HardwareProfile.Name) (can stall old/iGPU drivers)." -Warning
    }

    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) Remote Assistance..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value $Zero

    Write-Status -Types "-", $TweakType -Status "Disabling Ndu High RAM Usage..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value $(If ($Revert) { 2 } Else { 4 })

    # Will reduce Processes number considerably on > 4GB of RAM systems
    Write-Status -Types "+", $TweakType -Status "Setting SVCHost to match installed RAM size..."
    $RamInKB = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $RamInKB

    Write-Status -Types "*", $TweakType -Status "Enabling Windows Store apps Automatic Updates..."
    If (!(Test-Path "$PathToLMPoliciesWindowsStore")) {
        New-Item -Path "$PathToLMPoliciesWindowsStore" -Force | Out-Null
    }
    Remove-ItemPropertyVerified -Path "$PathToLMPoliciesWindowsStore" -Name "AutoDownload"

    Write-Section "Microsoft Edge Background Activity"
    Write-Caption "System and Performance"
    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) Edge Startup boost..."
    Set-ItemPropertyVerified -Path "$PathToLMPoliciesEdge" -Name "StartupBoostEnabled" -Type DWord -Value $Zero

    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) run extensions and apps when Edge is closed..."
    Set-ItemPropertyVerified -Path "$PathToLMPoliciesEdge" -Name "BackgroundModeEnabled" -Type DWord -Value $Zero

    Write-Section "Power Plan Tweaks"
    If ($PCSystemType -eq 1 -and -not $Revert) {
        Write-Status -Types "+", $TweakType -Status "Desktop ($PCSystemType): Setting Power Plan to High Performance..."
        powercfg -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    } ElseIf ($PCSystemType -eq 2) {
        Write-Status -Types "@", $TweakType -Status "Laptop ($PCSystemType): Keeping current power plan..." -Warning
    } Else {
        Write-Status -Types "@", $TweakType -Status "Unknown ($PCSystemType): Keeping current power plan..." -Warning
    }

    Write-Status -Types "+", $TweakType -Status "Creating the Ultimate Performance hidden Power Plan..."
    powercfg -DuplicateScheme e9a42b02-d5df-448d-aa00-03f14749eb61
    Unregister-DuplicatedPowerPlan
    Enable-Hibernate -Type 'Full'

    Write-Section "Network Stack Latency & Throughput"
    Write-Status -Types "+", $TweakType -Status "Unlimiting network bandwidth reservation..."
    Set-ItemPropertyVerified -Path "$PathToLMPoliciesPsched" -Name "NonBestEffortLimit" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    If (!$Revert) {
        Write-Status -Types "+", $TweakType -Status "Tuning TCP Auto-Tuning level (normal)..."
        Try { netsh int tcp set global autotuninglevel=normal | Out-Null } Catch { }

        Write-Status -Types "+", $TweakType -Status "Enabling Receive Side Scaling (RSS)..."
        Try { netsh int tcp set global rss=enabled | Out-Null } Catch { }

        Write-Status -Types "-", $TweakType -Status "Disabling TCP Chimney Offload (prevents micro-stuttering on cheap NICs)..."
        Try { netsh int tcp set global chimney=disabled | Out-Null } Catch { }

        Write-Status -Types "+", $TweakType -Status "Enabling Compound TCP (CTCP/CUBIC) congestion provider..."
        Try { netsh int tcp set supplemental template=custom congestionprovider=cubic | Out-Null } Catch { }
    } Else {
        Try { netsh int tcp set global autotuninglevel=normal | Out-Null } Catch { }
        Try { netsh int tcp set global rss=default | Out-Null } Catch { }
    }

    Write-Section "System & Apps Timeout behaviors"
    Write-Status -Types "+", $TweakType -Status "Reducing Time to services app timeout to 2s to ALL users..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -Type DWord -Value 2000
    Write-Status -Types "*", $TweakType -Status "Don't clear page file at shutdown to ALL users..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWord -Value 0

    Write-Status -Types "+", $TweakType -Status "Reducing mouse hover time events to 250ms..."
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime" -Type String -Value "250"

    ForEach ($DesktopRegistryPath in @($PathToUsersControlPanelDesktop, $PathToCUControlPanelDesktop)) {
        If ($DesktopRegistryPath -eq $PathToUsersControlPanelDesktop) {
            Write-Caption "TO ALL USERS"
        } ElseIf ($DesktopRegistryPath -eq $PathToCUControlPanelDesktop) {
            Write-Caption "TO CURRENT USER"
        }

        Write-Status -Types "+", $TweakType -Status "Don't prompt user to end tasks on shutdown..."
        Set-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "AutoEndTasks" -Type DWord -Value $(If ($Revert) { 0 } Else { 1 })

        Write-Status -Types "*", $TweakType -Status "Returning 'Hung App Timeout' to default..."
        Remove-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "HungAppTimeout"

        Write-Status -Types "+", $TweakType -Status "Reducing mouse and keyboard hooks timeout to 1s..."
        Set-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "LowLevelHooksTimeout" -Type DWord -Value $(If ($Revert) { 5000 } Else { 1000 })
        Write-Status -Types "+", $TweakType -Status "Reducing animation speed delay to 1ms on Windows 11..."
        Set-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "MenuShowDelay" -Type DWord -Value $(If ($Revert) { 400 } Else { 1 })
        Write-Status -Types "+", $TweakType -Status "Reducing Time to kill apps timeout to 5s..."
        Set-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "WaitToKillAppTimeout" -Type DWord -Value $(If ($Revert) { 20000 } Else { 5000 })
    }

    Write-Section "Explorer Startup Latency"
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Type DWord -Value $(If ($Revert) { 1000 } Else { 0 })

    Write-Section "Gaming Responsiveness Tweaks"
    If (!$Revert) {
        Disable-XboxGameBarDVRandMode
    } Else {
        Enable-XboxGameBarDVRandMode
    }

    Write-Status -Types "*", $TweakType -Status "Enabling game mode..."
    Set-ItemPropertyVerified -Path "$PathToCUGameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "$PathToCUGameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1

    Write-Status -Types "+", $TweakType -Status "Setting SystemResponsiveness to $($HardwareProfile.SystemResponsiveness)..."
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfile" -Name "SystemResponsiveness" -Type DWord -Value $HardwareProfile.SystemResponsiveness
    Write-Status -Types "+", $TweakType -Status "Dedicate more CPU/GPU usage to Gaming tasks..."
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfileOnGameTasks" -Name "GPU Priority" -Type DWord -Value 8
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfileOnGameTasks" -Name "Priority" -Type DWord -Value 6
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfileOnGameTasks" -Name "Scheduling Category" -Type String -Value "High"

    Write-Section "Storage & Disk I/O Latency"
    Write-Status -Types "+", $TweakType -Status "Disabling NTFS last-access update timestamps (cuts background I/O)..."
    If (!$Revert) {
        Try { fsutil behavior set disablelastaccess 1 | Out-Host } Catch { }
    } Else {
        Try { fsutil behavior set disablelastaccess 0 | Out-Host } Catch { }
    }

    Write-Status -Types "-", $TweakType -Status "Disabling Reserved Storage..."
    Try { DISM /Online /Set-ReservedStorageState /State:Disabled | Out-Host } Catch { }
}

If ($Revert -or $Global:Revert) {
    Optimize-Performance -Revert
} Else {
    Optimize-Performance
}
