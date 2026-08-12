Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"

# Windows System Integrity & Component Repair Utility

function Repair-WindowsSystem() {
    Write-Title "Repair Major Windows Problems & Image Corruption"

    Write-Section "Reset Windows Hosts File"
    $RestoreHosts = "# Copyright (c) 1993-2009 Microsoft Corp.`n#`n# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.`n#`n# This file contains the mappings of IP addresses to host names. Each`n# entry should be kept on an individual line. The IP address should`n# be placed in the first column followed by the corresponding host name.`n# The IP address and the host name should be separated by at least one`n# space.`n#`n# Additionally, comments (such as these) may be inserted on individual`n# lines or following the machine name denoted by a '#' symbol.`n#`n# For example:`n#`n#      102.54.94.97     rhino.acme.com          # source server`n#       38.25.63.10     x.acme.com              # x client host`n`n# localhost name resolution is handled within DNS itself.`n#    127.0.0.1       localhost`n#    ::1             localhost"

    Try {
        Push-Location -Path "$env:SystemRoot\System32\drivers\etc\"
        Write-Caption "Restoring default hosts file..."
        Set-Content -Path ".\hosts" -Value $RestoreHosts -Encoding ASCII -Force
        Pop-Location
    } Catch {
        Write-Status -Types "?", "Repair" -Status "Could not reset hosts file: $_" -Warning
    }

    Write-Section "Fix Missing Power Plans"
    Write-Caption "Restoring default Power Plans..."
    Try { powercfg -RestoreDefaultSchemes } Catch { }

    Write-Section "Fix Microsoft Store"
    Write-Caption "Running wsreset..."
    Try { Start-Process wsreset -NoNewWindow -Wait } Catch { }

    Write-Section "Fix Windows Taskbar & Shell Links"
    Write-Caption "Restoring Windows Taskbar DLL registrations..."
    Try {
        Start-Process -FilePath "$env:SystemRoot\System32\Regsvr32.exe" -ArgumentList "/s $env:SystemRoot\System32\msimtf.dll" -Wait | Out-Null
        Start-Process -FilePath "$env:SystemRoot\System32\Regsvr32.exe" -ArgumentList "/s $env:SystemRoot\System32\msctf.dll" -Wait | Out-Null
        Start-Process -Verb RunAs "$env:SystemRoot\System32\ctfmon.exe" | Out-Null
    } Catch { }

    Write-Section "Remove 'Test Mode' Watermark"
    Write-Caption "Disabling TestSigning on bcdedit..."
    Try { bcdedit -set TESTSIGNING OFF | Out-Host } Catch { }

    Write-Section "Remove BITS Stuck Jobs"
    Write-Caption "Removing pending BITS transfers..."
    Try { Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Remove-BitsTransfer -ErrorAction SilentlyContinue } Catch { }

    Write-Section "Fix Windows System File Integrity & DISM Image"
    Write-Caption "Running SFC scan..."
    Try { SFC /ScanNow | Out-Host } Catch { }
    Write-Caption "Running DISM component store repair..."
    Try { DISM /Online /Cleanup-Image /RestoreHealth | Out-Host } Catch { }

    Write-Section "Re-register AppX Manifests"
    Write-Caption "Re-registering provisioned Windows AppX packages..."
    Try {
        Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Where-Object { $_.InstallLocation } | ForEach-Object {
            If (Test-Path "$($_.InstallLocation)\AppXManifest.xml") {
                Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
            }
        }
    } Catch { }

    Write-Section "Reset Networking & Winsock Stack"
    Write-Caption "Flushing DNS cache..."
    Try { ipconfig /FlushDns | Out-Host } Catch { }

    Write-Caption "Resetting Winsock and IP stack..."
    Try { netsh winsock reset | Out-Host } Catch { }
    Try { netsh int ip reset | Out-Host } Catch { }

    Write-Status -Types "+", "Repair" -Status "System repair pass completed."
}

Repair-WindowsSystem
