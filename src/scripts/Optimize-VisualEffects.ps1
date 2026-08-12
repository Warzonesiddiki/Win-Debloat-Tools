Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareProfile.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Windows11-Tweaks.psm1"

function Optimize-VisualEffects {
    [CmdletBinding()]
    param (
        [Switch] $Revert,
        [Switch] $ForceAggressive
    )

    $TweakType = "Visual"
    Write-Title "Visual effects for smoothness"

    If ($Revert) {
        Write-Status -Types "*", $TweakType -Status "Restoring visual effects and transparency..." -Warning
        Enable-VisualAnimations
        Enable-TransparencyEffects
        return
    }

    $Profile = Get-HardwareProfile
    If ($ForceAggressive -or $env:WIN_DEBLOAT_PROFILE_OVERRIDE -eq 'ExtremeLowEnd') {
        Write-Status -Types "@", $TweakType -Status "Force-aggressive visual profile requested."
        $Profile = Resolve-HardwareProfile -RamGB 4 -CpuCores 2 -DriveType 'HDD' -FreeDiskGB $Profile.FreeDiskGB -IsLaptop $(If ($Profile.IsLaptop) { 1 } Else { 0 }) -OverrideName 'ExtremeLowEnd'
    }

    Write-Status -Types "@", $TweakType -Status "Profile $($Profile.Name): transparency=$($Profile.DisableTransparency) animations=$($Profile.DisableAnimations)"

    If ($Profile.DisableTransparency) {
        Disable-TransparencyEffects
    } Else {
        Enable-TransparencyEffects
    }

    If ($Profile.DisableAnimations -or $Profile.AggressiveVisuals) {
        Disable-VisualAnimations
        Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value "0"
        Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value $(If ($Profile.Name -eq 'ExtremeLowEnd') { "0" } Else { "1" })
    } ElseIf ($Profile.Name -eq 'MidRange') {
        Write-Status -Types "-", $TweakType -Status "Mid-range: keeping window contents, dropping shadows and peek..."
        Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
        Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 0
        Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value "50"
        Disable-TransparencyEffects
    } Else {
        Write-Status -Types "*", $TweakType -Status "High-end: leaving appearance mostly stock (transparency stays on)."
        Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value "100"
    }
}

$Force = ($env:WIN_DEBLOAT_FORCE_AGGRESSIVE -eq '1')
If ($Revert -or $Global:Revert) {
    Optimize-VisualEffects -Revert
} ElseIf ($Force) {
    Optimize-VisualEffects -ForceAggressive
} Else {
    Optimize-VisualEffects
}
