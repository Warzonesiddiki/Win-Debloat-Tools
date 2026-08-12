Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Get-HardwareProfile.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\ui\Show-MessageDialog.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Title-Templates.psm1"

function Get-RegistryDword {
    param ([String] $Path, [String] $Name, $Default = $null)
    Try {
        $Item = Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction Stop
        return $Item.$Name
    } Catch {
        return $Default
    }
}

function Show-SystemHealth {
    [CmdletBinding()]
    param (
        [Switch] $Silent
    )

    Write-Title "Windows 11 system health"

    $Profile = Get-HardwareProfile
    $Win = $Profile.Windows

    $Os = $null
    Try { $Os = Get-CimInstance -ClassName Win32_OperatingSystem } Catch { }
    $FreeRamGB = 0
    $TotalRamGB = $Profile.RamGB
    $ProcCount = 0
    Try {
        If ($Os) {
            $FreeRamGB = [Math]::Round($Os.FreePhysicalMemory / 1MB, 1)
            $TotalRamGB = [Math]::Round($Os.TotalVisibleMemorySize / 1MB, 1)
        }
        $ProcCount = @(Get-Process -ErrorAction SilentlyContinue).Count
    } Catch { }

    $UsedRamGB = [Math]::Round(($TotalRamGB - $FreeRamGB), 1)
    $RamPct = If ($TotalRamGB -gt 0) { [Math]::Round(($UsedRamGB / $TotalRamGB) * 100, 1) } Else { 0 }

    $Drive = Get-PSDrive -Name $env:SystemDrive[0] -ErrorAction SilentlyContinue
    $FreeDisk = If ($Drive) { [Math]::Round($Drive.Free / 1GB, 1) } Else { 0 }
    $UsedDisk = If ($Drive) { [Math]::Round($Drive.Used / 1GB, 1) } Else { 0 }
    $TotalDisk = $FreeDisk + $UsedDisk

    $CopilotOff = (Get-RegistryDword "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 0) -eq 1
    $RecallOff = (Get-RegistryDword "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement" 1) -eq 0
    $WidgetsOff = (Get-RegistryDword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 1) -eq 0
    $TransparencyOff = (Get-RegistryDword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 1) -eq 0
    $VisualFx = Get-RegistryDword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 0
    $SysMain = "unknown"
    $Search = "unknown"
    Try { $SysMain = (Get-Service SysMain -ErrorAction SilentlyContinue).StartType } Catch { }
    Try { $Search = (Get-Service WSearch -ErrorAction SilentlyContinue).StartType } Catch { }

    $Vbs = "unknown"
    Try {
        $Vbs = Get-RegistryDword "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" "Enabled" "n/a"
    } Catch { }

    $StartupCount = 0
    ForEach ($Path in @(
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
        )) {
        If (Test-Path $Path) {
            $Props = (Get-Item $Path).Property | Where-Object { $_ -ne '(default)' }
            $StartupCount += @($Props).Count
        }
    }

    $Title = "Windows 11 System Health"
    $Message = @"
Profile: $($Profile.Name)
Hardware: $($Profile.RamGB) GB RAM | $($Profile.CpuCores) cores | $($Profile.DriveType)
Windows: $($Win.Caption) $($Win.DisplayVersion) ($($Win.CurrentBuild).$($Win.UBR))
Form factor: $(If ($Profile.IsLaptop) { 'Laptop' } Else { 'Desktop' })
-----------------------------------------------------------------
RAM used: $UsedRamGB / $TotalRamGB GB ($RamPct%)
Disk used ($env:SystemDrive): $UsedDisk / $TotalDisk GB ($FreeDisk GB free)
Processes: $ProcCount
User+Machine Run startups: $StartupCount
-----------------------------------------------------------------
Copilot policy off: $CopilotOff
Recall blocked: $RecallOff
Widgets hidden: $WidgetsOff
Transparency off: $TransparencyOff
VisualFX setting: $VisualFx (2 = best performance)
SysMain: $SysMain
Windows Search: $Search
Memory Integrity (HVCI) enabled: $Vbs
-----------------------------------------------------------------
Recommendations:
$(If ($Profile.IsConstrained) { '- This PC is constrained. Use "Optimize for Low-End PC" then reboot.' } Else { '- Hardware is comfortable. Apply Tweaks is enough.' })
$(If ($FreeRamGB -lt 1.5) { '- Free RAM is critically low. Close browsers and disable startups.' } Else { '- RAM headroom looks acceptable after a reboot.' })
$(If ($FreeDisk -lt 15) { '- Disk is almost full. Run Disk Cleanup + Remove Temporary Files.' } Else { '- Disk space is OK.' })
- Defender, Windows Update, networking, and audio are never disabled by this toolkit.
"@

    Write-Host "`n$Message`n" -ForegroundColor Cyan
    If (-not $Silent) {
        Show-MessageDialog -Title $Title -Message $Message
    }
}

Show-SystemHealth
