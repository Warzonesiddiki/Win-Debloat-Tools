Import-Module -DisableNameChecking "$PSScriptRoot\Title-Templates.psm1"

function Get-CPU() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Switch] $NameOnly,
        [String] $Separator = '|'
    )

    $CPUName = ""

    Try {
        ForEach ($Item in (Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0").ProcessorNameString.Trim(" ").Split(" ")) {
            If (($Item -ne " ") -and ($null -ne $Item) -and ($Item.Length -gt 0)) {
                $CPUName = ($CPUName.Trim(" ") + " " + $Item.Trim(" ")).Trim()
            }
        }
    } Catch {
        Try {
            $CPUName = (Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue).Name.Trim()
        } Catch {
            $CPUName = "Generic CPU"
        }
    }

    If ($NameOnly) {
        return "$CPUName"
    }

    $CoreCount = 4
    Try {
        $CoreCount = (Get-CimInstance -class Win32_processor).NumberOfCores
    } Catch { }

    $CPUCoresAndThreads = "($CoreCount" + "C/" + "$env:NUMBER_OF_PROCESSORS" + "T)"
    return "$Env:PROCESSOR_ARCHITECTURE $Separator $CPUName $CPUCoresAndThreads"
}

function Test-IsLowPowerCpu {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [String] $CpuName = ''
    )

    If (-not $CpuName) {
        $CpuName = Get-CPU -NameOnly
    }

    # Matches Intel U/Y series (e.g. i7-10510U, i5-8250U, i7-1165G7), Celeron, Pentium, Athlon, Atom, N-series
    If ($CpuName -match '(?i)[0-9]{4,5}[UY]\b|[0-9]{4}G[1-7]\b|Celeron|Pentium|Athlon|Atom|N[0-9]{3,4}\b|Core\(TM\)\s+m[357]|Ryzen\s+[357]\s+[0-9]{4}U\b') {
        return $true
    }
    return $false
}

function Get-GPU() {
    [CmdletBinding()]
    [OutputType([String])]

    $GpuNames = @()
    Try {
        $Controllers = Get-CimInstance -Class Win32_VideoController -ErrorAction SilentlyContinue
        ForEach ($Gpu in $Controllers) {
            If ($Gpu.Name -and ($GpuNames -notcontains $Gpu.Name)) {
                $GpuNames += $Gpu.Name.Trim()
            }
        }
    } Catch { }

    If ($GpuNames.Count -eq 0) {
        return "Generic Display Adapter"
    }

    return ($GpuNames -join ", ")
}

function Get-GpuDetails {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param ()

    $GpuList = @()
    $HasNvidia = $false
    $HasIntel = $false
    $HasAmd = $false
    $MaxVramBytes = 0

    Try {
        $Controllers = Get-CimInstance -Class Win32_VideoController -ErrorAction SilentlyContinue
        ForEach ($Gpu in $Controllers) {
            $GpuName = [String]$Gpu.Name
            $GpuList += $GpuName
            If ($GpuName -match '(?i)NVIDIA|GeForce|Quadro|RTX|GTX|MX[0-9]{3}') { $HasNvidia = $true }
            If ($GpuName -match '(?i)Intel|UHD|Iris|HD Graphics') { $HasIntel = $true }
            If ($GpuName -match '(?i)AMD|Radeon') { $HasAmd = $true }

            $Vram = [Int64]$Gpu.AdapterRAM
            If ($Vram -gt $MaxVramBytes) { $MaxVramBytes = $Vram }
        }
    } Catch { }

    $VramGB = [Double]($MaxVramBytes / 1GB)
    $IsDualGpu = ($GpuList.Count -ge 2) -or ($HasIntel -and ($HasNvidia -or $HasAmd))
    $IsEntryGpu = ($GpuList -match '(?i)MX[0-9]{3}|GTX\s+1050\b|Radeon\s+5[234]0\b|Intel|UHD|Iris|HD Graphics').Count -gt 0

    return [PSCustomObject]@{
        GpuList       = $GpuList
        PrimaryGpu    = $(If ($GpuList.Count -gt 0) { $GpuList[0] } Else { "Generic GPU" })
        HasNvidia     = $HasNvidia
        HasIntel      = $HasIntel
        HasAmd        = $HasAmd
        IsDualGpu     = $IsDualGpu
        IsEntryGpu    = $IsEntryGpu
        VramGB        = [Math]::Round($VramGB, 1)
        Summary       = ($GpuList -join ", ")
    }
}

function Get-RAM() {
    [CmdletBinding()]
    [OutputType([String])]

    $RamInGB = 8
    $RAMSpeed = "Unknown"
    Try {
        $RamInGB = [Math]::Round(((Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB), 1)
        $RAMSpeed = (Get-CimInstance -ClassName Win32_PhysicalMemory).Speed[0]
    } Catch { }

    return "$RamInGB`GB ($RAMSpeed`MHz)"
}

function Get-RAMGigabytes() {
    [CmdletBinding()]
    [OutputType([Double])]

    Try {
        return [Double]((Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)
    } Catch {
        return [Double]8
    }
}

function Get-OSArchitecture() {
    [CmdletBinding()]
    param (
        $Architecture = (Get-ComputerInfo -Property OSArchitecture)
    )

    If ($Architecture -like "*64*bit*") {
        $Architecture = @("x64")
    } ElseIf ($Architecture -like "*32*bit*") {
        $Architecture = @("x86")
    } ElseIf (($Architecture -like "*ARM") -and ($Architecture -like "*64")) {
        $Architecture = @("arm64")
    } ElseIf ($Architecture -like "*ARM") {
        $Architecture = @("arm")
    } Else {
        Write-Host "[?] Couldn't identify the System Architecture '$Architecture'. :/" -ForegroundColor Yellow -BackgroundColor Black
        $Architecture = $null
    }

    Write-Warning "$Architecture OS detected!"
    return $Architecture
}

function Get-OSDriveType() {
    [CmdletBinding()]
    [OutputType([String])]

    # Adapted from: https://stackoverflow.com/a/62087930
    Try {
        $SystemDriveType = Get-PhysicalDisk | ForEach-Object {
            $PhysicalDisk = $_
            $PhysicalDisk | Get-Disk | Get-Partition |
            Where-Object DriveLetter -EQ "$($env:SystemDrive[0])" | Select-Object DriveLetter, @{ n = 'MediaType'; e = { $PhysicalDisk.MediaType } }
        }
        $OSDriveType = $SystemDriveType.MediaType
        If ($OSDriveType -and $OSDriveType -ne 'Unspecified') {
            return "$OSDriveType"
        }
    } Catch { }

    # Fallback to volume query
    Try {
        $DriveLetter = $env:SystemDrive[0]
        $Disk = Get-Disk | Where-Object { (Get-Partition -DiskNumber $_.Number -ErrorAction SilentlyContinue | Where-Object DriveLetter -eq $DriveLetter) }
        If ($Disk -and $Disk.BusType -in @('NVMe', 'SATA', 'RAID') -and $Disk.MediaType -match 'SSD') {
            return "SSD"
        }
    } Catch { }

    return "SSD"
}

function Get-DriveSpace() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String] $DriveLetter = $env:SystemDrive[0]
    )

    $SystemDrive = (Get-PSDrive -Name $DriveLetter)
    $AvailableStorage = $SystemDrive.Free / 1GB
    $UsedStorage = $SystemDrive.Used / 1GB
    $TotalStorage = $AvailableStorage + $UsedStorage

    return "$DriveLetter`: $([Math]::Round($AvailableStorage, 1))/$([Math]::Round($TotalStorage, 1)) GB ($([Math]::Round(($AvailableStorage / $TotalStorage) * 100, 1))%)"
}

function Get-PCSystemType() {
    [CmdletBinding()]

    $PCSystemType = 1
    Try {
        $PCSystemType = (Get-CimInstance -Class Win32_ComputerSystem).PCSystemType
    } Catch { }

    # Fallback: check battery or chassis
    If ($PCSystemType -ne 2) {
        Try {
            If (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue) {
                $PCSystemType = 2
            }
        } Catch { }
    }

    If ($PCSystemType -eq 1) {
        Write-Status -Types "@", "Info" -Status "Your PC is a Desktop ($PCSystemType)" -Warning
    } ElseIf ($PCSystemType -eq 2) {
        Write-Status -Types "@", "Info" -Status "Your PC is a Laptop ($PCSystemType)" -Warning
    } Else {
        Write-Status -Types "?", "Info" -Status "Your PC system type is Unknown ($PCSystemType)" -Warning
    }

    return $PCSystemType
}

function Get-SystemSpec() {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [String] $Separator = '|'
    )

    Write-Status -Types "@", "Info" -Status "Loading system specs..."
    $WinVer = "Windows 11"
    $DisplayVersion = "24H2"
    Try {
        $WinVer = (Get-CimInstance -class Win32_OperatingSystem).Caption -replace 'Microsoft ', ''
        $DisplayVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
        $OldBuildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
        $DisplayVersion = If ($DisplayVersion) { $DisplayVersion } Else { $OldBuildNumber }
    } Catch { }

    $DisplayedVersionResult = "($DisplayVersion)"
    return $(Get-OSDriveType), $Separator, $WinVer, $DisplayedVersionResult, $Separator, $(Get-RAM), $Separator, $(Get-CPU -Separator $Separator), $Separator, $(Get-GPU)
}
