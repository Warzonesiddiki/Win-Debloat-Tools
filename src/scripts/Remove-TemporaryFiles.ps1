Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemVerified.psm1"

function Remove-TemporaryFiles() {
    $TweakType = "Temp"
    Write-Title "Deep System Cache & Temporary Files Cleanup"

    $PathsToClean = @(
        "$env:SystemRoot\Temp\*"
        "$env:TEMP\*"
        "$env:LOCALAPPDATA\Temp\*"
        "$env:SystemRoot\SoftwareDistribution\Download\*"
        "$env:SystemDrive\`$WinREAgent"
        "$env:SystemDrive\`$SysReset"
        "$env:SystemDrive\`$Windows.~WS"
        "$env:SystemDrive\`$GetCurrent"
        "$env:SystemDrive\ESD"
        "$env:SystemDrive\PerfLogs"
        "$env:LOCALAPPDATA\CrashDumps\*"
        "$env:SystemRoot\Minidump\*"
        "$env:SystemRoot\MEMORY.DMP"
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db"
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db"
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*"
        "$env:LOCALAPPDATA\Microsoft\Windows\WebCache\*"
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*"
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache\*"
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*"
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache\*"
    )

    ForEach ($Path in $PathsToClean) {
        If (Test-Path -Path $Path) {
            Write-Status -Types "+", $TweakType -Status "Purging temporary artifacts in '$Path'..."
            Remove-ItemVerified -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Status -Types "+", $TweakType -Status "Temporary files and system cache purge completed."
}

Remove-TemporaryFiles
