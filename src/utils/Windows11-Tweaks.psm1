Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-OptionalFeatureState.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ServiceStartup.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-UWPApp.psm1"

# Windows 11 22H2-25H2 individual toggles. Every disable has a matching enable.

function Disable-WindowsCopilot {
    Write-Status -Types "-", "Win11" -Status "Disabling Microsoft Copilot (taskbar, policy, app)..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\Shell\Copilot\BingChat" -Name "IsUserEligible" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Type DWord -Value 0
    Try {
        Remove-UWPApp -AppxPackages @(
            "Microsoft.Copilot"
            "Microsoft.Windows.Ai.Copilot.Provider"
            "MicrosoftWindows.Client.CoPilot"
        )
    } Catch {
        Write-Status -Types "?", "Win11" -Status "Copilot AppX removal skipped: $_" -Warning
    }
}

function Enable-WindowsCopilot {
    Write-Status -Types "*", "Win11" -Status "Restoring Microsoft Copilot policies..."
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot"
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\Shell\Copilot\BingChat" -Name "IsUserEligible"
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled"
}

function Disable-WindowsRecall {
    Write-Status -Types "-", "Win11" -Status "Disabling Windows Recall snapshots and policies..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "AllowRecallEnablement" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "TurnOffSavingSnapshots" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableAIDataAnalysis" -Type DWord -Value 1
    Try {
        Set-OptionalFeatureState -State 'Disabled' -OptionalFeatures @("Recall")
    } Catch {
        Write-Status -Types "?", "Win11" -Status "Recall optional feature not present or already off." -Warning
    }
}

function Enable-WindowsRecall {
    Write-Status -Types "*", "Win11" -Status "Restoring Windows Recall policies..."
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis"
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis"
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "AllowRecallEnablement"
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "TurnOffSavingSnapshots"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableAIDataAnalysis"
}

function Disable-ClickToDo {
    Write-Status -Types "-", "Win11" -Status "Disabling Click to Do / AI text & image analysis..."
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableClickToDo" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\Shell\ClickToDo" -Name "DisableClickToDo" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarCopilotEnabled" -Type DWord -Value 0
}

function Enable-ClickToDo {
    Write-Status -Types "*", "Win11" -Status "Restoring Click to Do..."
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableClickToDo"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\Shell\ClickToDo" -Name "DisableClickToDo"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarCopilotEnabled"
}

function Disable-WidgetsBoard {
    Write-Status -Types "-", "Win11" -Status "Disabling Widgets / News and Interests board..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0
}

function Enable-WidgetsBoard {
    Write-Status -Types "*", "Win11" -Status "Restoring Widgets board policies..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 1
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests"
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds"
}

function Disable-StartRecommended {
    Write-Status -Types "-", "Win11" -Status "Hiding Recommended section in Start..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Type DWord -Value 0
}

function Enable-StartRecommended {
    Write-Status -Types "*", "Win11" -Status "Restoring Start Recommended section..."
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection"
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications"
}

function Disable-TransparencyEffects {
    Write-Status -Types "-", "Win11" -Status "Disabling transparency / Mica / Acrylic effects..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0
}

function Enable-TransparencyEffects {
    Write-Status -Types "*", "Win11" -Status "Enabling transparency effects..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 1
}

function Disable-VisualAnimations {
    Write-Status -Types "-", "Perf" -Status "Setting visual effects for snappy low-end performance..."
    # VisualFXSetting: 2 = Adjust for best performance
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 2
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00))
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value "0"
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Type DWord -Value 0
    # Keep text readable and File Explorer usable
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Type String -Value "2"
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewWatermark" -Type DWord -Value 0
}

function Enable-VisualAnimations {
    Write-Status -Types "*", "Perf" -Status "Restoring Windows visual effects defaults..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 0
    Remove-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask"
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value "1"
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1
}

function Disable-FastStartup {
    Write-Status -Types "-", "Perf" -Status "Disabling Fast Startup (cleaner full shutdowns)..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0
}

function Enable-FastStartup {
    Write-Status -Types "*", "Perf" -Status "Enabling Fast Startup..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 1
}

function Disable-EdgeAI {
    Write-Status -Types "-", "Win11" -Status "Disabling Microsoft Edge Copilot / Compose AI..."
    $Edge = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    Set-ItemPropertyVerified -Path $Edge -Name "HubsSidebarEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path $Edge -Name "CopilotPageContext" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path $Edge -Name "CopilotCDPPageContext" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path $Edge -Name "ComposeInlineEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path $Edge -Name "NewTabPageHideDefaultTopSites" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path $Edge -Name "ShowRecommendationsEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path $Edge -Name "SpotlightExperiencesAndRecommendationsEnabled" -Type DWord -Value 0
}

function Enable-EdgeAI {
    Write-Status -Types "*", "Win11" -Status "Restoring Microsoft Edge AI policies..."
    $Edge = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    @("HubsSidebarEnabled", "CopilotPageContext", "CopilotCDPPageContext", "ComposeInlineEnabled", "NewTabPageHideDefaultTopSites", "ShowRecommendationsEnabled", "SpotlightExperiencesAndRecommendationsEnabled") | ForEach-Object {
        Remove-ItemPropertyVerified -Path $Edge -Name $_
    }
}

function Disable-PaintAI {
    Write-Status -Types "-", "Win11" -Status "Disabling Paint Cocreator / Generative Fill..."
    $Paint = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint"
    Set-ItemPropertyVerified -Path $Paint -Name "DisableCocreator" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path $Paint -Name "DisableGenerativeFill" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path $Paint -Name "DisableImageCreator" -Type DWord -Value 1
}

function Enable-PaintAI {
    Write-Status -Types "*", "Win11" -Status "Restoring Paint AI features..."
    $Paint = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint"
    @("DisableCocreator", "DisableGenerativeFill", "DisableImageCreator") | ForEach-Object {
        Remove-ItemPropertyVerified -Path $Paint -Name $_
    }
}

function Disable-NotepadAI {
    Write-Status -Types "-", "Win11" -Status "Disabling Notepad AI rewrite / Copilot..."
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Notepad" -Name "DisableAIFeatures" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Notepad" -Name "EnableWritingTools" -Type DWord -Value 0
}

function Enable-NotepadAI {
    Write-Status -Types "*", "Win11" -Status "Restoring Notepad AI features..."
    Remove-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Notepad" -Name "DisableAIFeatures"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Notepad" -Name "EnableWritingTools"
}

function Disable-WindowsAIService {
    Write-Status -Types "-", "Win11" -Status "Setting Windows AI Fabric service to Manual..."
    Set-ServiceStartup -State 'Manual' -Services @("WSAIFabricSvc")
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSAIFabricSvc" -Name "Start" -Type DWord -Value 3
}

function Enable-WindowsAIService {
    Write-Status -Types "*", "Win11" -Status "Restoring Windows AI Fabric service default..."
    Set-ServiceStartup -State 'Manual' -Services @("WSAIFabricSvc")
}

function Enable-TaskbarEndTask {
    Write-Status -Types "+", "Win11" -Status "Enabling End Task on the taskbar context menu..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDeveloperSettings" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask" -Type DWord -Value 1
}

function Disable-TaskbarEndTask {
    Write-Status -Types "*", "Win11" -Status "Hiding End Task on the taskbar..."
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask"
}

function Disable-ExplorerGallery {
    Write-Status -Types "-", "Win11" -Status "Hiding Gallery from File Explorer..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 0
}

function Enable-ExplorerGallery {
    Write-Status -Types "*", "Win11" -Status "Restoring Gallery in File Explorer..."
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" -Name "System.IsPinnedToNameSpaceTree"
}

function Disable-ExplorerHome {
    Write-Status -Types "-", "Win11" -Status "Hiding Home from File Explorer navigation..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 0
}

function Enable-ExplorerHome {
    Write-Status -Types "*", "Win11" -Status "Restoring Home in File Explorer..."
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" -Name "System.IsPinnedToNameSpaceTree"
}

function Enable-StorageSenseLowEnd {
    Write-Status -Types "+", "Perf" -Status "Enabling Storage Sense to reclaim disk automatically..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "04" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "08" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "32" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "2048" -Type DWord -Value 30
}

function Disable-StorageSenseLowEnd {
    Write-Status -Types "*", "Perf" -Status "Disabling Storage Sense..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 0
}

function Disable-VBSMemoryIntegrity {
    Write-Status -Types "-", "Perf" -Status "Disabling Memory Integrity (HVCI). This trades security for FPS/CPU on low-end PCs..." -Warning
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Type DWord -Value 0
}

function Enable-VBSMemoryIntegrity {
    Write-Status -Types "+", "Security" -Status "Enabling Memory Integrity (HVCI)..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Type DWord -Value 1
}
