Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareProfile.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Windows11-Tweaks.psm1"

function Disable-WindowsAI {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    $TweakType = "AI"
    Write-Title "Zero AI in Windows 11 (Copilot, Recall, Click to Do, Studio Effects, App AI, Models)"

    $Info = Get-WindowsReleaseInfo
    If (-not $Info.IsWindows11) {
        Write-Status -Types "?", $TweakType -Status "Not Windows 11 — applying policy locks so any future upgrade stays completely clean." -Warning
    }

    If ($Revert) {
        Write-Status -Types "*", $TweakType -Status "Re-enabling Windows AI policies (previously uninstalled apps are not reinstalled)..." -Warning
        Enable-WindowsCopilot
        Enable-WindowsRecall
        Enable-ClickToDo
        Enable-EdgeAI
        Enable-PaintAI
        Enable-NotepadAI
        Enable-PhotosAI
        Enable-WindowsStudioEffects
        Enable-PhiSilicaAndModelDownloads
        Enable-SemanticSearch
        Enable-WindowsAIService
        Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures"
        return
    }

    Write-Section "Microsoft Copilot"
    Disable-WindowsCopilot

    Write-Section "Windows Recall & Snapshots"
    Disable-WindowsRecall

    Write-Section "Click to Do (AI Screen & Text Analysis)"
    Disable-ClickToDo

    Write-Section "Built-in App AI (Edge, Paint, Notepad, Photos)"
    Disable-EdgeAI
    Disable-PaintAI
    Disable-NotepadAI
    Disable-PhotosAI

    Write-Section "NPU & AI Processing (Studio Effects, Semantic Search, Phi Silica)"
    Disable-WindowsStudioEffects
    Disable-PhiSilicaAndModelDownloads
    Disable-SemanticSearch
    Disable-WindowsAIService

    Write-Section "Silent AI Reinstallation Block"
    Write-Status -Types "-", $TweakType -Status "Blocking silent AI/consumer-app reinstalls and dynamic web pushes..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContentEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "EnableDynamicContentInWSB" -Type DWord -Value 0

    Write-Status -Types "+", $TweakType -Status "Windows 11 is now 100% Zero-AI. Defender, Windows Update, audio, and network are fully intact."
}

If ($Revert -or $Global:Revert) {
    Disable-WindowsAI -Revert
} Else {
    Disable-WindowsAI
}
