Import-Module -DisableNameChecking "$PSScriptRoot\Get-HardwareInfo.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\Title-Templates.psm1"

# Hardware-aware Windows 11 profiles.
# ExtremeLowEnd / LowEnd / MidRange / HighEnd decide how aggressive tweaks are.
# Override with $env:WIN_DEBLOAT_PROFILE_OVERRIDE = 'ExtremeLowEnd'

function Resolve-HardwareProfile {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [Double] $RamGB,
        [Parameter(Mandatory)]
        [Int]    $CpuCores,
        [Parameter(Mandatory)]
        [String] $DriveType,
        [Double] $FreeDiskGB = 64,
        [Int]    $IsLaptop = 0,
        [String] $OverrideName = '',
        [Bool]   $IsLowPowerCpu = $false,
        [Double] $DedicatedVramGB = 0.0,
        [Bool]   $IsDualGpu = $false
    )

    $NormalizedDrive = 'SSD'
    If ($DriveType -match '(?i)HDD|Unspecified|UnspecifiedHDD|^$') {
        $NormalizedDrive = 'HDD'
    } ElseIf ($DriveType -match '(?i)SSD|NVMe|SCM|SSD') {
        $NormalizedDrive = 'SSD'
    } Else {
        $NormalizedDrive = $DriveType
    }

    $Name = 'HighEnd'
    If ($RamGB -le 4.5 -or ($RamGB -le 6.5 -and $NormalizedDrive -eq 'HDD')) {
        $Name = 'ExtremeLowEnd'
    } ElseIf ($RamGB -le 8.5 -or $NormalizedDrive -eq 'HDD' -or $CpuCores -le 2) {
        $Name = 'LowEnd'
    } ElseIf ($RamGB -le 16.5 -or ($IsLaptop -and $IsLowPowerCpu) -or ($DedicatedVramGB -gt 0 -and $DedicatedVramGB -le 2.0)) {
        $Name = 'MidRange'
    }

    If ($OverrideName -and $OverrideName -in @('ExtremeLowEnd', 'LowEnd', 'MidRange', 'HighEnd')) {
        $Name = $OverrideName
    }

    $IsConstrained = $Name -in @('ExtremeLowEnd', 'LowEnd')
    # Entry GPUs (<=2GB VRAM or mobile U-series iGPUs) and non-high-end benefit from disabling transparency
    $DisableTransparency = ($Name -ne 'HighEnd') -or ($DedicatedVramGB -gt 0 -and $DedicatedVramGB -le 2.0) -or ($IsLaptop -and $IsLowPowerCpu)
    # HAGS is beneficial on desktop modern dGPUs, but should be skipped on entry 2GB mobile dGPUs or old Pascal MX chips
    $EnableHAGS = ($Name -in @('MidRange', 'HighEnd')) -and -not ($DedicatedVramGB -gt 0 -and $DedicatedVramGB -le 2.0) -and -not ($IsLaptop -and $IsLowPowerCpu)

    return [PSCustomObject]@{
        Name                   = $Name
        RamGB                  = [Math]::Round($RamGB, 1)
        CpuCores               = $CpuCores
        DriveType              = $NormalizedDrive
        FreeDiskGB             = [Math]::Round($FreeDiskGB, 1)
        IsLaptop               = [Bool]$IsLaptop
        IsLowPowerCpu          = [Bool]$IsLowPowerCpu
        DedicatedVramGB        = [Math]::Round($DedicatedVramGB, 1)
        IsDualGpu              = [Bool]$IsDualGpu
        IsConstrained          = $IsConstrained
        DisableSysMain         = ($IsConstrained -or $NormalizedDrive -eq 'HDD')
        DisableSearch          = ($Name -eq 'ExtremeLowEnd' -or $NormalizedDrive -eq 'HDD' -or $RamGB -le 8.5)
        AggressiveVisuals      = $IsConstrained
        DisableTransparency    = $DisableTransparency
        DisableAnimations      = $IsConstrained
        UseCompactOS           = (($FreeDiskGB -lt 20) -or ($Name -eq 'ExtremeLowEnd' -and $FreeDiskGB -lt 40))
        DisableHibernate       = ((-not [Bool]$IsLaptop) -and ($Name -eq 'ExtremeLowEnd' -or $FreeDiskGB -lt 15))
        SystemResponsiveness   = 10
        EnableHAGS             = $EnableHAGS
        PagefileStrategy       = $(If ($Name -eq 'ExtremeLowEnd') { 'FixedLowRam' } Else { 'SystemManaged' })
        KeepMemoryCompression  = $true
        ProtectDefender        = $true
        ProtectWindowsUpdate   = $true
    }
}

function Get-InstalledRamGB {
    [CmdletBinding()]
    [OutputType([Double])]
    param ()

    Try {
        $Bytes = (Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction Stop | Measure-Object -Property Capacity -Sum).Sum
        If ($Bytes -gt 0) {
            return [Double]($Bytes / 1GB)
        }
    } Catch {
        Write-Verbose "Win32_PhysicalMemory failed: $_"
    }

    Try {
        $Total = (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory
        return [Double]($Total / 1GB)
    } Catch {
        return [Double]8
    }
}

function Get-LogicalCpuCores {
    [CmdletBinding()]
    [OutputType([Int])]
    param ()

    Try {
        $Cores = (Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop | Measure-Object -Property NumberOfCores -Sum).Sum
        If ($Cores -gt 0) { return [Int]$Cores }
    } Catch {
        Write-Verbose "Win32_Processor failed: $_"
    }

    If ($env:NUMBER_OF_PROCESSORS) {
        return [Int]$env:NUMBER_OF_PROCESSORS
    }
    return 4
}

function Get-SystemDriveFreeGB {
    [CmdletBinding()]
    [OutputType([Double])]
    param ()

    Try {
        $Letter = $env:SystemDrive[0]
        $Drive = Get-PSDrive -Name $Letter -ErrorAction Stop
        return [Double]($Drive.Free / 1GB)
    } Catch {
        return [Double]64
    }
}

function Get-WindowsReleaseInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param ()

    $Caption = ''
    $DisplayVersion = ''
    $CurrentBuild = 0
    $UBR = 0

    Try {
        $Os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $Caption = [String]$Os.Caption
    } Catch {
        $Caption = [String]$env:OS
    }

    Try {
        $Nt = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction Stop
        $DisplayVersion = [String]$Nt.DisplayVersion
        $CurrentBuild = [Int]$Nt.CurrentBuild
        $UBR = [Int]$Nt.UBR
    } Catch {
        Write-Verbose "Windows NT CurrentVersion unavailable: $_"
    }

    $IsWindows11 = ($CurrentBuild -ge 22000) -or ($Caption -match 'Windows 11')
    $Is24H2OrNewer = ($CurrentBuild -ge 26100) -or ($DisplayVersion -in @('24H2', '25H2', '26H1', '26H2'))
    $Is25H2OrNewer = ($DisplayVersion -in @('25H2', '26H1', '26H2')) -or ($CurrentBuild -ge 26200)

    return [PSCustomObject]@{
        Caption         = $Caption
        DisplayVersion  = $DisplayVersion
        CurrentBuild    = $CurrentBuild
        UBR             = $UBR
        IsWindows11     = [Bool]$IsWindows11
        Is24H2OrNewer   = [Bool]$Is24H2OrNewer
        Is25H2OrNewer   = [Bool]$Is25H2OrNewer
    }
}

function Get-HardwareProfile {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Switch] $Quiet
    )

    $Override = [String]$env:WIN_DEBLOAT_PROFILE_OVERRIDE
    $RamGB = Get-InstalledRamGB
    $Cores = Get-LogicalCpuCores
    $DriveType = 'Unspecified'
    Try { $DriveType = Get-OSDriveType } Catch { $DriveType = 'Unspecified' }
    $FreeDisk = Get-SystemDriveFreeGB
    $PcType = 1
    Try { $PcType = Get-PCSystemType } Catch { $PcType = 1 }
    $IsLaptop = $(If ($PcType -eq 2) { 1 } Else { 0 })

    $IsLowPowerCpu = Test-IsLowPowerCpu
    $GpuInfo = Get-GpuDetails

    $Profile = Resolve-HardwareProfile -RamGB $RamGB -CpuCores $Cores -DriveType $DriveType -FreeDiskGB $FreeDisk -IsLaptop $IsLaptop -OverrideName $Override -IsLowPowerCpu $IsLowPowerCpu -DedicatedVramGB $GpuInfo.VramGB -IsDualGpu $GpuInfo.IsDualGpu
    $Win = Get-WindowsReleaseInfo

    $Profile | Add-Member -NotePropertyName 'Windows' -NotePropertyValue $Win -Force
    $Profile | Add-Member -NotePropertyName 'GpuInfo' -NotePropertyValue $GpuInfo -Force

    $GpuSummary = If ($GpuInfo.Summary) { " | " + $GpuInfo.Summary } Else { "" }
    $Profile | Add-Member -NotePropertyName 'Summary' -NotePropertyValue ("{0} | {1:N1}GB RAM | {2}C | {3} | {4:N1}GB free | {5} {6}{7}" -f $Profile.Name, $Profile.RamGB, $Profile.CpuCores, $Profile.DriveType, $Profile.FreeDiskGB, $Win.Caption, $Win.DisplayVersion, $GpuSummary) -Force

    If (-not $Quiet) {
        Write-Status -Types "@", "Profile" -Status $Profile.Summary
    }

    return $Profile
}

function Get-ProtectedServiceList {
    [CmdletBinding()]
    [OutputType([String[]])]
    param ()

    return @(
        'WinDefend'
        'WdNisSvc'
        'Sense'
        'mdcoreSvc'
        'wscsvc'
        'SecurityHealthService'
        'wuauserv'
        'UsoSvc'
        'WaaSMedicSvc'
        'Dhcp'
        'Dnscache'
        'NlaSvc'
        'netprofm'
        'nsi'
        'Audiosrv'
        'AudioEndpointBuilder'
        'RpcSs'
        'RpcEptMapper'
        'DcomLaunch'
        'LSM'
        'EventLog'
        'PlugPlay'
        'Power'
        'ProfSvc'
        'SamSs'
        'Schedule'
        'Winmgmt'
        'BrokerInfrastructure'
        'SystemEventsBroker'
        'UserManager'
        'CoreMessagingRegistrar'
        'StateRepository'
        'FontCache'
        'WlanSvc'
        'BFE'
        'mpssvc'
        'CryptSvc'
        'LanmanWorkstation'
        'LanmanServer'
        'Spooler'
    )
}

function Test-ProtectedService {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [Parameter(Mandatory)]
        [String] $Name
    )

    return ((Get-ProtectedServiceList) -contains $Name)
}
