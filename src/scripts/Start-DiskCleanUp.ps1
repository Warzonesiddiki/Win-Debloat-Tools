Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareInfo.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"

function Start-DiskCleanUp() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Switch] $Silent,
        [Switch] $ResetBase,
        [Switch] $Trim
    )

    $CleanOptions = @(
        "Active Setup Temp Folders"
        "BranchCache"
        "D3D Shader Cache"
        "Delivery Optimization Files"
        "Diagnostic Data Viewer database files"
        "Downloaded Program Files"
        "Feedback Hub Archive log files"
        "Internet Cache Files"
        "Language Pack"
        "Old ChkDsk Files"
        "Recycle Bin"
        "RetailDemo Offline Content"
        "Setup Log Files"
        "System error memory dump files"
        "System error minidump files"
        "Temporary Files"
        "Temporary Setup Files"
        "Thumbnail Cache"
        "Update Cleanup"
        "User file versions"
        "Windows Defender"
        "Windows Error Reporting Files"
        "Windows Upgrade Log Files"
    )
    $PathToLMCleangmrSettings = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    $TweakType = "Disk"

    Write-Status -Types "+", $TweakType -Status "Cleaning the $env:SystemRoot\WinSxS component store..."
    If ($ResetBase) {
        DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Host
    } Else {
        DISM /Online /Cleanup-Image /StartComponentCleanup | Out-Host
    }

    Write-Status -Types "+", $TweakType -Status "Cleaning up system caches and temporary files..."
    If (!$Silent) {
        Start-Process cleanmgr.exe -ArgumentList "/d $env:SystemDrive", "/VERYLOWDISK" -Wait
    } Else {
        ForEach ($Key in $CleanOptions) {
            Set-ItemPropertyVerified -Path "$PathToLMCleangmrSettings\$Key" -Name "StateFlags0777" -Type DWord -Value 2
        }

        Start-Process cleanmgr.exe -ArgumentList "/d $env:SystemDrive", "/SAGERUN:777" -Wait
    }

    $DriveType = "SSD"
    Try { $DriveType = Get-OSDriveType } Catch { }
    $Letter = $env:SystemDrive[0]

    If ($DriveType -match '(?i)SSD|NVMe') {
        Write-Status -Types "+", $TweakType -Status "Running SSD TRIM on volume $Letter`:..."
        Try { Optimize-Volume -DriveLetter $Letter -ReTrim -ErrorAction SilentlyContinue | Out-Host } Catch { }
    } Else {
        Write-Status -Types "+", $TweakType -Status "Analyzing HDD volume $Letter`:..."
        Try { Optimize-Volume -DriveLetter $Letter -Analyze -ErrorAction SilentlyContinue | Out-Host } Catch { }
    }

    Write-Status -Types "+", $TweakType -Status "Disk cleanup and volume optimization completed."
}

Start-DiskCleanUp -Silent
