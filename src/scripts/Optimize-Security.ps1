Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareInfo.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Individual-Tweaks.psm1"

# Windows Security Hardening Optimizer (Defender & Firewall Guarded)

function Optimize-Security() {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    $TweakType = "Security"
    $PathToLMPoliciesEdge = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge"
    $PathToLMPoliciesMRT = "HKLM:\SOFTWARE\Policies\Microsoft\MRT"
    $PathToCUExplorer = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    $PathToCUExplorerAdvanced = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    Write-Title "Security Hardening Tweaks"

    If ($Revert) {
        Write-Status -Types "*", $TweakType -Status "Reverting security customizations..." -Warning
        Enable-SearchAppForUnknownExt
        Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 2
        return
    }

    Write-Section "Windows Firewall"
    Write-Status -Types "+", $TweakType -Status "Enabling default firewall profiles..."
    Try { Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True -ErrorAction SilentlyContinue } Catch { }

    Write-Section "Windows Defender Protection"
    Write-Status -Types "+", $TweakType -Status "Ensuring Microsoft Defender is fully ENABLED..."
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 0
    Try { Set-MpPreference -DisableRealtimeMonitoring $false -Force -ErrorAction SilentlyContinue } Catch { }
    Try { Set-MpPreference -EnableNetworkProtection Enabled -Force -ErrorAction SilentlyContinue } Catch { }
    Try { Set-MpPreference -PUAProtection Enabled -Force -ErrorAction SilentlyContinue } Catch { }

    Write-Section "SmartScreen & Exploitation Defense"
    Write-Status -Types "+", $TweakType -Status "Enabling SmartScreen for Edge and Store Apps..."
    Set-ItemPropertyVerified -Path "$PathToLMPoliciesEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 1

    Write-Section "Legacy Protocols & Insecure Handlers"
    Write-Status -Types "+", $TweakType -Status "Disabling SMB 1.0 legacy protocol..."
    Try { Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue } Catch { }

    Write-Section "Autoplay & Autorun Defense"
    Write-Status -Types "-", $TweakType -Status "Disabling Autoplay and Autorun for removable media..."
    Set-ItemPropertyVerified -Path "$PathToCUExplorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

    Write-Section "Explorer & Store Protections"
    Disable-SearchAppForUnknownExt
    Set-ItemPropertyVerified -Path "$PathToCUExplorerAdvanced" -Name "HideFileExt" -Type DWord -Value 0

    Write-Section "User Account Control (UAC)"
    Write-Status -Types "+", $TweakType -Status "Enforcing secure desktop prompt on UAC elevation..."
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1

    Write-Section "Malicious Software Removal Tool (MSRT)"
    Set-ItemPropertyVerified -Path "$PathToLMPoliciesMRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 0
}

If ($Revert -or $Global:Revert) {
    Optimize-Security -Revert
} Else {
    Optimize-Security
}
