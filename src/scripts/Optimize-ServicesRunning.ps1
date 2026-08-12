Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareInfo.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareProfile.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ServiceStartup.psm1"

# Hardware-Aware & Zero-AI Windows Services Optimizer

function Optimize-ServicesRunning() {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    $HardwareProfile = Get-HardwareProfile
    $IsSystemDriveSSD = $HardwareProfile.DriveType -eq "SSD"
    $EnableServicesOnSSD = @()
    If (-not $HardwareProfile.DisableSysMain) { $EnableServicesOnSSD += "SysMain" }
    If (-not $HardwareProfile.DisableSearch) { $EnableServicesOnSSD += "WSearch" }

    # Services which will be totally disabled (telemetry, AI, diagnostic hogs)
    $ServicesToDisabled = @(
        "DiagTrack"                                 # Connected User Experiences and Telemetry
        "diagnosticshub.standardcollector.service"  # Diagnostics Hub Standard Collector Service
        "dmwappushservice"                          # Device Management Wireless Application Protocol (WAP)
        "Fax"                                       # Fax Service
        "fhsvc"                                     # File History Service
        "GraphicsPerfSvc"                           # Graphics performance monitor service
        "HomeGroupListener"                         # HomeGroup Listener (Legacy)
        "HomeGroupProvider"                         # HomeGroup Provider (Legacy)
        "lfsvc"                                     # Geolocation Service
        "MapsBroker"                                # Downloaded Maps Manager
        "PcaSvc"                                    # Program Compatibility Assistant (PCA)
        "RemoteAccess"                              # Routing and Remote Access
        "RemoteRegistry"                            # Remote Registry
        "RetailDemo"                                # Retail Demo Service
        "SysMain"                                   # SysMain / Superfetch (100% Disk usage on HDDs / constrained RAM)
        "TrkWks"                                    # Distributed Link Tracking Client
        "WSearch"                                   # Windows Search Indexing (Heavy disk I/O on HDDs)
        "WSAIFabricSvc"                             # Windows AI Fabric (Copilot+ / 24H2+ NPU/AI Service)
        "TroubleshootingSvc"                        # Recommended Troubleshooting Service
        "WalletService"                             # Windows Wallet & NFC
    )

    # Making services run on-demand only (Manual)
    $ServicesToManual = @(
        "BITS"                           # Background Intelligent Transfer Service
        "edgeupdate"                     # Microsoft Edge Update Service
        "edgeupdatem"                    # Microsoft Edge Update Service (Manual)
        "PhoneSvc"                       # Phone Service
        "SCardSvr"                       # Smart Card Service
        "stisvc"                         # Windows Image Acquisition (WIA) Service
        "WbioSrvc"                       # Windows Biometric Service
        "wisvc"                          # Windows Insider Program Service
        "WMPNetworkSvc"                  # Windows Media Player Network Sharing Service
        "WpnService"                     # Windows Push Notification Services (WNS)
        <# Bluetooth services #>
        "BTAGService"                    # Bluetooth Audio Gateway Service
        "BthAvctpSvc"                    # AVCTP Service
        "bthserv"                        # Bluetooth Support Service
        "RtkBtManServ"                   # Realtek Bluetooth Device Manager Service
        <# Diagnostic Services #>
        "DPS"                            # Diagnostic Policy Service
        "WdiServiceHost"                 # Diagnostic Service Host
        "WdiSystemHost"                  # Diagnostic System Host
        <# Network Services #>
        "iphlpsvc"                       # IP Helper Service
        "lmhosts"                        # TCP/IP NetBIOS Helper
        "SharedAccess"                   # Internet Connection Sharing (ICS)
        <# Telemetry Services #>
        "Wecsvc"                         # Windows Event Collector Service
        "WerSvc"                         # Windows Error Reporting Service
        <# Xbox services #>
        "XblAuthManager"                 # Xbox Live Auth Manager
        "XblGameSave"                    # Xbox Live Game Save
        "XboxGipSvc"                     # Xbox Accessory Management Service
        "XboxNetApiSvc"                  # Xbox Live Networking Service
        <# 3rd Party Services #>
        "gupdate"                        # Google Update Service
        "gupdatem"                       # Google Update Service (Manual)
    )

    $ServicesToAutomatic = @()

    Write-Title "Hardware-Aware & Privacy Services Optimization"
    Write-Section "Disabling Telemetry, AI, and Unnecessary Services"

    If ($Revert) {
        Write-Status -Types "*", "Service" -Status "Reverting services to default manual startup..." -Warning
        Set-ServiceStartup -State 'Manual' -Services $ServicesToDisabled -Filter $EnableServicesOnSSD
    } Else {
        Set-ServiceStartup -State 'Disabled' -Services $ServicesToDisabled -Filter $EnableServicesOnSSD
    }

    Write-Section "Managing Search / SysMain & Hardware-Aware Services"
    If (($IsSystemDriveSSD -or $Revert) -and $EnableServicesOnSSD.Count -gt 0) {
        Set-ServiceStartup -State 'Automatic' -Services $EnableServicesOnSSD
    }

    Set-ServiceStartup -State 'Manual' -Services $ServicesToManual
    If ($ServicesToAutomatic.Count -gt 0) {
        Set-ServiceStartup -State 'Automatic' -Services $ServicesToAutomatic
    }
}

If ($Revert -or $Global:Revert) {
    Optimize-ServicesRunning -Revert
} Else {
    Optimize-ServicesRunning
}
