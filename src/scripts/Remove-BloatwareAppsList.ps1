Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-UWPApp.psm1"

function Remove-BloatwareAppsList() {
    $MSApps = @(
        # Default Windows 10/11 bloatware
        "Microsoft.3DBuilder"                    # 3D Builder
        "Microsoft.549981C3F5F10"                # Cortana
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"                  # Finance
        "Microsoft.BingFoodAndDrink"             # Food And Drink
        "Microsoft.BingHealthAndFitness"         # Health And Fitness
        "Microsoft.BingNews"                     # News
        "Microsoft.BingSports"                   # Sports
        "Microsoft.BingTranslator"               # Translator
        "Microsoft.BingTravel"                   # Travel
        "Microsoft.BingWeather"                  # Weather
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.Copilot"                      # Copilot App
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"                   # Tips / Get Started
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection" # MS Solitaire
        "Microsoft.MixedReality.Portal"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"               # MS Office One Note (UWP)
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.MSPaint"                      # Paint 3D
        "Microsoft.People"                       # People
        "Microsoft.PowerAutomateDesktop"         # Power Automate
        "Microsoft.Print3D"                      # Print 3D
        "Microsoft.SkypeApp"                     # Skype
        "Microsoft.Todos"                        # Microsoft To Do
        "Microsoft.Wallet"
        "Microsoft.Whiteboard"                   # Microsoft Whiteboard
        "Microsoft.WindowsAlarms"                # Alarms
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"           # Feedback Hub
        "Microsoft.WindowsMaps"                  # Maps
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsReadingList"
        "Microsoft.WindowsSoundRecorder"         # Windows Sound Recorder
        "Microsoft.XboxApp"                      # Xbox Console Companion
        "Microsoft.YourPhone"                    # Your Phone
        "Microsoft.ZuneMusic"                    # Groove Music / (New) Windows Media Player
        "Microsoft.ZuneVideo"                    # Movies & TV
        "MicrosoftWindows.Client.CoPilot"        # Copilot Dependency
        "Microsoft.Windows.Ai.Copilot.Provider"  # Copilot Provider
        "Microsoft.BingSearch"                   # Bing Search / Search Highlights
        "Microsoft.StartExperiencesApp"          # Start recommendations feed
        "Microsoft.Windows.DevHome"              # Dev Home
        "Microsoft.Windows.DevHomeGitHubExtension"
        "Microsoft.Windows.DevHomeAzureExtension"
        "Microsoft.Windows.SemanticSearch"       # Semantic Search
        "Microsoft.Windows.SearchInsights"       # Search Insights
        "MicrosoftWindows.CrossDevice"           # Phone Link / Cross Device
        "Microsoft.WidgetsPlatformRuntime"       # Widgets runtime
        "Microsoft.MicrosoftPCManager"           # PC Manager
        "Microsoft.Edge.GameAssist"              # Edge Game Assist
        "MicrosoftCorporationII.MicrosoftFamily" # Family Safety
        "Microsoft.MicrosoftJournal"             # Journal
        "MicrosoftTeams"                         # Classic Teams package name
        "Clipchamp.Clipchamp"				     # Clipchamp – Video Editor
        "Microsoft.OutlookForWindows"            # Microsoft Outlook (Web Wrapper)
        "M*S*Teams"                              # Microsoft Teams (24H2 or older)
        "MicrosoftWindows.Client.WebExperience"  # Taskbar Widgets
        "Microsoft.Advertising.Xaml"             # Advertising Xaml
    )

    $ThirdPartyApps = @(
        "*ACGMediaPlayer*"
        "*ActiproSoftwareLLC*"
        "*AdobePhotoshopExpress*"           # Adobe Photoshop Express
        "Amazon.com.Amazon"                 # Amazon Shop
        "*Asphalt8Airborne*"                # Asphalt 8 Airbone
        "*AutodeskSketchBook*"
        "*BubbleWitch3Saga*"                # Bubble Witch 3 Saga
        "*CaesarsSlotsFreeCasino*"
        "*CandyCrush*"                      # Candy Crush
        "*COOKINGFEVER*"
        "*CyberLinkMediaSuiteEssentials*"
        "*DisneyMagicKingdoms*"
        "*Dolby*"                           # Dolby Products
        "*DrawboardPDF*"
        "*Duolingo-LearnLanguagesforFree*"  # Duolingo
        "*EclipseManager*"
        "*FarmVille2CountryEscape*"
        "*FitbitCoach*"
        "*Flipboard*"                       # Flipboard
        "*HiddenCity*"
        "*Keeper*"
        "*LinkedInforWindows*"
        "*MarchofEmpires*"
        "*NYTCrossword*"
        "*OneCalendar*"
        "*PandoraMediaInc*"
        "*PhototasticCollage*"
        "*PicsArt-PhotoStudio*"
        "*PolarrPhotoEditorAcademicEdition*"
        "*RoyalRevolt*"                     # Royal Revolt
        "*Shazam*"
        "*Sidia.LiveWallpaper*"             # Live Wallpaper
        "*Speed Test*"
        "*Sway*"
        "*WinZipUniversal*"
        "*Wunderlist*"
        "*XING*"
    )

    $ManufacturerApps = @(
        # Dell Bloat
        "DB6EA5DB.MediaSuiteEssentialsforDell"
        "DB6EA5DB.PowerDirectorforDell"
        "DB6EA5DB.Power2GoforDell"
        "DB6EA5DB.PowerMediaPlayerforDell"
        "DellInc.DellCustomerConnect"           # Dell Customer Connect
        "DellInc.DellDigitalDelivery"           # Dell Digital Delivery
        "DellInc.DellHelpSupport"
        "DellInc.DellProductRegistration"
        "DellInc.MyDell"                        # My Dell

        # SAMSUNG Bloat
        "SAMSUNGELECTRONICSCO.LTD.1412377A9806A"
        "SAMSUNGELECTRONICSCO.LTD.NewVoiceNote"
        "SAMSUNGELECTRONICSCoLtd.SamsungNotes"
        "SAMSUNGELECTRONICSCoLtd.SamsungFlux"
        "SAMSUNGELECTRONICSCO.LTD.StudioPlus"
        "SAMSUNGELECTRONICSCO.LTD.SamsungWelcome"
        "SAMSUNGELECTRONICSCO.LTD.SamsungUpdate"
        "SAMSUNGELECTRONICSCO.LTD.SamsungSecurity1.2"
        "SAMSUNGELECTRONICSCO.LTD.SamsungScreenRecording"
        "SAMSUNGELECTRONICSCO.LTD.SamsungQuickSearch"
        "SAMSUNGELECTRONICSCO.LTD.SamsungPCCCleaner"
        "SAMSUNGELECTRONICSCO.LTD.SamsungCloudBluetoothSync"
        "SAMSUNGELECTRONICSCO.LTD.PCGallery"
        "SAMSUNGELECTRONICSCO.LTD.OnlineSupportSService"
        "4AE8B7C2.BOOKING.COMPARTNERAPPSAMSUNGEDITION"
    )

    $SocialMediaApps = @(
        "BytedancePte.Ltd.TikTok"   # TikTok
        "FACEBOOK.317180B0BB486"    # Messenger
        "FACEBOOK.FACEBOOK"         # Facebook
        "Facebook.Instagram*"       # Instagram
        "*Twitter*"                 # Twitter / X
        "*Viber*"
    )

    $StreamingServicesApps = @(
        "AmazonVideo.PrimeVideo"    # Amazon Prime Video
        "*Hulu*"
        "*iHeartRadio*"
        "*Netflix*"                 # Netflix
        "*Plex*"                    # Plex
        "*SlingTV*"
        "SpotifyAB.SpotifyMusic"    # Spotify
        "*TuneInRadio*"
    )

    Write-Title "Remove Windows Unneeded Apps (Bloatware & Stubs)"
    Write-Section "Microsoft Bloat & AI Apps"
    Remove-UWPApp -AppxPackages $MSApps
    Write-Section "3rd-Party Junk Apps"
    Remove-UWPApp -AppxPackages $ThirdPartyApps
    Write-Section "Manufacturer OEM Bloat"
    Remove-UWPApp -AppxPackages $ManufacturerApps
    Write-Section "Social Media Apps"
    Remove-UWPApp -AppxPackages $SocialMediaApps
    Write-Section "Streaming Services Apps"
    Remove-UWPApp -AppxPackages $StreamingServicesApps
}

Remove-BloatwareAppsList
