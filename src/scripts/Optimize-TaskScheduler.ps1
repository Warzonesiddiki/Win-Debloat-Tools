Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ScheduledTaskState.psm1"

# Telemetry, CEIP, Diagnostics & AI Scheduled Tasks Optimizer

function Optimize-TaskScheduler() {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    $DisableScheduledTasks = @(
        "\Microsoft\Office\OfficeTelemetryAgentLogOn"
        "\Microsoft\Office\OfficeTelemetryAgentFallBack"
        "\Microsoft\Office\Office 15 Subscription Heartbeat"
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
        "\Microsoft\Windows\Application Experience\StartupAppTask"
        "\Microsoft\Windows\Application Experience\AitAgent"
        "\Microsoft\Windows\Application Experience\PcaPatchDbTask"
        "\Microsoft\Windows\Application Experience\MareBackup"
        "\Microsoft\Windows\Autochk\Proxy"
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
        "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
        "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
        "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM"
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
        "\Microsoft\Windows\Location\Notifications"
        "\Microsoft\Windows\Location\WindowsActionDialog"
        "\Microsoft\Windows\Maps\MapsToastTask"
        "\Microsoft\Windows\Maps\MapsUpdateTask"
        "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"
        "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
        "\Microsoft\Windows\Retail Demo\CleanupOfflineContent"
        "\Microsoft\Windows\Shell\FamilySafetyMonitor"
        "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
        "\Microsoft\Windows\Shell\FamilySafetyUpload"
        "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"
        "\Microsoft\Windows\Feedback\Siuf\DmClient"
        "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
        "\Microsoft\Windows\Flighting\FeatureConfig\ReconcileFeatures"
        "\Microsoft\Windows\Flighting\FeatureConfig\UsageDataFlushing"
        "\Microsoft\Windows\Flighting\FeatureConfig\UsageDataReporting"
        "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
        "\Microsoft\Windows\DiskFootprint\Diagnostics"
        "\Microsoft\Windows\NetTrace\GatherNetworkInfo"
        "\Microsoft\Windows\PI\Sqm-Tasks"
        "\Microsoft\Windows\PushToInstall\LoginCheck"
        "\Microsoft\Windows\PushToInstall\Registration"
        "\Microsoft\Windows\Device Information\Device"
        "\Microsoft\Windows\Diagnosis\Scheduled"
        "\Microsoft\Windows\Speech\SpeechModelDownloadTask"
    )

    $EnableScheduledTasks = @(
        "\Microsoft\Windows\Defrag\ScheduledDefrag"                 # Defragments / Trims internal storages
        "\Microsoft\Windows\Maintenance\WinSAT"                     # WinSAT system configuration detection
        "\Microsoft\Windows\RecoveryEnvironment\VerifyWinRE"        # Verify Recovery Environment integrity on boot
        "\Microsoft\Windows\Windows Error Reporting\QueueReporting" # Error reporting queue
    )

    Write-Title "Scheduled Tasks Telemetry & Diagnostics Optimizer"
    Write-Section "Disabling Telemetry & Bloat Scheduled Tasks"

    If ($Revert) {
        Write-Status -Types "*", "TaskScheduler" -Status "Re-enabling scheduled tasks..." -Warning
        Set-ScheduledTaskState -State 'Enabled' -ScheduledTasks $DisableScheduledTasks
    } Else {
        Set-ScheduledTaskState -State 'Disabled' -ScheduledTasks $DisableScheduledTasks
    }

    Write-Section "Ensuring Essential Maintenance Tasks Stay Enabled"
    Set-ScheduledTaskState -State 'Enabled' -ScheduledTasks $EnableScheduledTasks
}

If ($Revert -or $Global:Revert) {
    Optimize-TaskScheduler -Revert
} Else {
    Optimize-TaskScheduler
}
