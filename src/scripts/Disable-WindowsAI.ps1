Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareProfile.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Windows11-Tweaks.psm1"

function Disable-WindowsAI {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    $TweakType = "AI"
    Write-Title "Windows 11 AI surfaces (Copilot, Recall, Click to Do, Edge/Paint/Notepad)"

    $Info = Get-WindowsReleaseInfo
    If (-not $Info.IsWindows11) {
        Write-Status -Types "?", $TweakType -Status "Not Windows 11 — applying policy locks only so 24H2 upgrades stay clean." -Warning
    }

    If ($Revert) {
        Write-Status -Types "*", $TweakType -Status "Re-enabling Windows AI policies (apps are not silently reinstalled)..." -Warning
        Enable-WindowsCopilot
        Enable-WindowsRecall
        Enable-ClickToDo
        Enable-EdgeAI
        Enable-PaintAI
        Enable-NotepadAI
        Enable-WindowsAIService
        return
    }

    Write-Section "Copilot"
    Disable-WindowsCopilot

    Write-Section "Recall"
    Disable-WindowsRecall

    Write-Section "Click to Do"
    Disable-ClickToDo

    Write-Section "Built-in app AI"
    Disable-EdgeAI
    Disable-PaintAI
    Disable-NotepadAI
    Disable-WindowsAIService

    Write-Section "Silent reinstall lock"
    Write-Status -Types "-", $TweakType -Status "Blocking silent consumer-app reinstalls (Copilot comes back via this channel)..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContentEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "EnableDynamicContentInWSB" -Type DWord -Value 0

    Write-Status -Types "+", $TweakType -Status "Windows AI surfaces disabled. Defender, Update, and Store are untouched."
}

If ($Revert -or $Global:Revert) {
    Disable-WindowsAI -Revert
} Else {
    Disable-WindowsAI
}
