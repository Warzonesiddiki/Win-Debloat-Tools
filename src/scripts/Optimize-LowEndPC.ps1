Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareProfile.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ServiceStartup.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Individual-Tweaks.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Windows11-Tweaks.psm1"

function Optimize-LowEndPC {
    [CmdletBinding()]
    param (
        [Switch] $Revert,
        [Switch] $ForceAggressive
    )

    $TweakType = "LowEnd"
    Write-Title "Low-end Windows 11 smoothness pass"

    If ($Revert) {
        Write-Status -Types "*", $TweakType -Status "Reverting low-end-only extras (core revert still handled by other scripts)..." -Warning
        Enable-BackgroundAppsToogle
        Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec"
        return
    }

    $Profile = Get-HardwareProfile
    If ($ForceAggressive -or $env:WIN_DEBLOAT_FORCE_AGGRESSIVE -eq '1') {
        Write-Status -Types "@", $TweakType -Status "Forcing ExtremeLowEnd decisions (Low-End Turbo / CLI LowEnd)."
        $env:WIN_DEBLOAT_PROFILE_OVERRIDE = 'ExtremeLowEnd'
        $Profile = Get-HardwareProfile
    }

    Write-Status -Types "@", $TweakType -Status $Profile.Summary
    Write-Status -Types "@", $TweakType -Status "SysMain=$($Profile.DisableSysMain) Search=$($Profile.DisableSearch) CompactOS=$($Profile.UseCompactOS) HibernateOff=$($Profile.DisableHibernate)"

    Write-Section "Background noise"
    Disable-BackgroundAppsToogle
    Disable-ClipboardHistory
    Disable-ClipboardSyncAcrossDevice
    Disable-WindowsSpotlight
    Disable-NewsAndInterest
    Disable-PhoneLink

    Write-Section "Boot and desktop latency"
    Write-Status -Types "+", $TweakType -Status "Removing Explorer startup delay..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Type String -Value "1"
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Type String -Value "3000"
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Type String -Value "2000"
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "LowLevelHooksTimeout" -Type String -Value "1000"
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value "0"
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -Type String -Value "2000"
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value $Profile.SystemResponsiveness
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    Write-Section "Prefetch policy"
    # Prefetch: 0 off, 1 app, 2 boot, 3 both. Keep both — it helps HDD and does not hurt SSD.
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Type DWord -Value 3
    If ($Profile.DisableSysMain) {
        Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Type DWord -Value 0
    } Else {
        Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Type DWord -Value 3
    }

    Write-Section "Notifications and tips"
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_TOASTS_ENABLED" -Type DWord -Value 0

    Write-Section "Delivery Optimization / P2P"
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 0

    Write-Section "Game Bar / DVR (always off on constrained PCs)"
    If ($Profile.IsConstrained) {
        Disable-XboxGameBarDVRandMode
        Disable-WidgetsBoard
        Disable-TransparencyEffects
        Disable-VisualAnimations
        Disable-FastStartup
    }

    Write-Section "Power"
    If (-not $Profile.IsLaptop) {
        Write-Status -Types "+", $TweakType -Status "Desktop: High Performance power plan..."
        powercfg -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        powercfg -Change Monitor-Timeout-AC 15
        powercfg -Change Standby-Timeout-AC 0
        powercfg -Change Disk-Timeout-AC 0
    } Else {
        Write-Status -Types "@", $TweakType -Status "Laptop: leaving the current plan, disabling USB selective suspend only..." -Warning
        Try {
            powercfg -SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
            powercfg -SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
            powercfg -SetActive SCHEME_CURRENT
        } Catch { }
    }

    Write-Status -Types "+", $TweakType -Status "Low-end pass finished. Reboot once for animations, SysMain, and Copilot to fully drop."
}

$Force = ($env:WIN_DEBLOAT_FORCE_AGGRESSIVE -eq '1')
If ($Revert -or $Global:Revert) {
    Optimize-LowEndPC -Revert
} ElseIf ($Force) {
    Optimize-LowEndPC -ForceAggressive
} Else {
    Optimize-LowEndPC
}
