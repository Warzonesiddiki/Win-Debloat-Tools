Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Save-TweakState.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"

function Get-StartupBloatPattern {
    return @(
        'OneDrive'
        'OneDriveSetup'
        'Microsoft.OneDrive'
        'Teams'
        'com.squirrel.Teams'
        'Microsoft Teams'
        'Skype'
        'Spotify'
        'Discord'
        'Steam'
        'EpicGamesLauncher'
        'EpicGames'
        'AdobeGCInvoker'
        'AdobeAAM'
        'AdobeGC'
        'CCXProcess'
        'CCleaner'
        'uTorrent'
        'Cortana'
        'Lync'
        'iTunesHelper'
        'ApplePush'
        'com.apple'
        'Opera'
        'Opera GX'
        'ChromeRemoteDesktop'
        'GoogleDriveSync'
        'Dropbox'
        'Facebook'
        'TikTok'
        'YourPhone'
        'PhoneExperienceHost'
        'WidgetService'
        'MicrosoftEdgeAutoLaunch'
        'Microsoft.PlusHelp'
        'Copilot'
        'GameBar'
        'Xbox'
    )
}

function Test-StartupNameIsBloat {
    param ([String] $Name, [String] $Command)

    $Haystack = "$Name $Command"
    ForEach ($Pattern in (Get-StartupBloatPattern)) {
        If ($Haystack -like "*$Pattern*") {
            return $true
        }
    }
    return $false
}

function Test-StartupNameIsProtected {
    param ([String] $Name, [String] $Command)

    $Haystack = "$Name $Command"
    $Keep = @(
        'SecurityHealth'
        'Windows Defender'
        'RtkAud'
        'Realtek'
        'NVIDIA'
        'AMD'
        'Intel'
        'HotKey'
        'SynTP'
        'igfx'
        'Persistence'
        'Audio'
    )
    ForEach ($Pattern in $Keep) {
        If ($Haystack -like "*$Pattern*") { return $true }
    }
    return $false
}

function Optimize-StartupApps {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    $TweakType = "Startup"
    Write-Title "Startup app cleanup"

    $StateName = "startup-backup.json"
    $RunPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    )

    If ($Revert) {
        Write-Status -Types "*", $TweakType -Status "Restoring previously removed startup entries..." -Warning
        $Saved = Read-TweakState -Name $StateName
        If ($Saved.State -and $Saved.State.Entries) {
            ForEach ($Entry in $Saved.State.Entries) {
                Set-ItemPropertyVerified -Path $Entry.Path -Name $Entry.Name -Type String -Value $Entry.Value
            }
        } Else {
            Write-Status -Types "?", $TweakType -Status "No startup backup found." -Warning
        }
        return
    }

    $Removed = @()
    ForEach ($Path in $RunPaths) {
        If (!(Test-Path -LiteralPath $Path)) { Continue }
        $Item = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
        If (-not $Item) { Continue }
        ForEach ($Name in $Item.Property) {
            If ($Name -eq '(default)') { Continue }
            $Value = [String](Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction SilentlyContinue).$Name
            If (Test-StartupNameIsProtected -Name $Name -Command $Value) {
                Write-Status -Types "?", $TweakType -Status "Keeping protected startup entry '$Name'."
                Continue
            }
            If (Test-StartupNameIsBloat -Name $Name -Command $Value) {
                Write-Status -Types "-", $TweakType -Status "Disabling startup '$Name'"
                $Removed += [PSCustomObject]@{ Path = $Path; Name = $Name; Value = $Value }
                Remove-ItemPropertyVerified -Path $Path -Name $Name -Force
            }
        }
    }

    Write-Section "OneDrive / Edge / Teams auto-launch leftovers"
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Discord" -Force
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Spotify" -Force
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Steam" -Force
    Remove-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" -Force

    Write-Status -Types "+", $TweakType -Status "Removing per-user Startup folder shortcuts that match bloat patterns..."
    $StartupDirs = @(
        [Environment]::GetFolderPath('Startup')
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    )
    ForEach ($Dir in $StartupDirs) {
        If (!(Test-Path -LiteralPath $Dir)) { Continue }
        Get-ChildItem -LiteralPath $Dir -File -ErrorAction SilentlyContinue | ForEach-Object {
            If (Test-StartupNameIsBloat -Name $_.BaseName -Command $_.FullName) {
                Write-Status -Types "-", $TweakType -Status "Removing shortcut $($_.Name)"
                Try { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop } Catch { }
            }
        }
    }

    Write-TweakState -Name $StateName -InputObject @{
        SavedAt = (Get-Date).ToString('o')
        Entries = $Removed
    }

    Write-Status -Types "+", $TweakType -Status "Startup cleanup done. $($Removed.Count) registry auto-starts removed (backed up)."
}

If ($Revert -or $Global:Revert) {
    Optimize-StartupApps -Revert
} Else {
    Optimize-StartupApps
}
