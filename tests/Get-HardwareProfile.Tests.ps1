# Pester-compatible (or standalone) checks for Resolve-HardwareProfile.
# Run on Windows:  pwsh -File tests/Get-HardwareProfile.Tests.ps1
# Linux CI uses tests/test_hardware_profile.py instead.

$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Module = Join-Path $Here "..\src\lib\Get-HardwareProfile.psm1"

# Title-Templates / CIM are not required for Resolve-HardwareProfile itself,
# but the module imports them. Dot-source only the function if imports fail.
Try {
    Import-Module -DisableNameChecking $Module -Force
} Catch {
    Write-Host "Full module import failed (expected on non-Windows). Parsing function only."
}

function Assert-Eq($Actual, $Expected, $Name) {
    If ($Actual -ne $Expected) {
        throw "FAIL $Name : expected '$Expected' got '$Actual'"
    }
    Write-Host "PASS $Name"
}

$Extreme = Resolve-HardwareProfile -RamGB 4 -CpuCores 2 -DriveType 'HDD' -FreeDiskGB 20 -IsLaptop 0
Assert-Eq $Extreme.Name 'ExtremeLowEnd' '4GB HDD is ExtremeLowEnd'
Assert-Eq $Extreme.DisableSysMain $true 'Extreme disables SysMain'
Assert-Eq $Extreme.EnableHAGS $false 'Extreme skips HAGS'
Assert-Eq $Extreme.SystemResponsiveness 10 'Responsiveness stays 10'
Assert-Eq $Extreme.KeepMemoryCompression $true 'Memory compression stays on'
Assert-Eq $Extreme.ProtectDefender $true 'Defender stays protected'

$Low = Resolve-HardwareProfile -RamGB 8 -CpuCores 4 -DriveType 'SSD' -FreeDiskGB 80 -IsLaptop 0
Assert-Eq $Low.Name 'LowEnd' '8GB SSD is LowEnd'
Assert-Eq $Low.DisableSearch $true '8GB disables Search'

$Mid = Resolve-HardwareProfile -RamGB 16 -CpuCores 6 -DriveType 'SSD' -FreeDiskGB 200 -IsLaptop 0
Assert-Eq $Mid.Name 'MidRange' '16GB SSD is MidRange'
Assert-Eq $Mid.EnableHAGS $true 'Mid enables HAGS'

$High = Resolve-HardwareProfile -RamGB 32 -CpuCores 8 -DriveType 'NVMe' -FreeDiskGB 400 -IsLaptop 0
Assert-Eq $High.Name 'HighEnd' '32GB NVMe is HighEnd'
Assert-Eq $High.DisableTransparency $false 'High keeps transparency'

$TargetMachine = Resolve-HardwareProfile -RamGB 20 -CpuCores 4 -DriveType 'SSD' -FreeDiskGB 422 -IsLaptop 1 -IsLowPowerCpu $true -DedicatedVramGB 2.0 -IsDualGpu $true
Assert-Eq $TargetMachine.Name 'MidRange' 'i7-10510U 20GB MX330 Laptop is MidRange'
Assert-Eq $TargetMachine.DisableSysMain $false 'Target machine keeps SysMain on SSD'
Assert-Eq $TargetMachine.DisableSearch $false 'Target machine keeps Search on SSD'
Assert-Eq $TargetMachine.DisableTransparency $true 'Target machine disables transparency for 2GB MX330 VRAM efficiency'
Assert-Eq $TargetMachine.EnableHAGS $false 'Target machine skips HAGS on 2GB MX330'
Assert-Eq $TargetMachine.UseCompactOS $false 'Target machine skips CompactOS with 422GB free'

$Laptop = Resolve-HardwareProfile -RamGB 4 -CpuCores 2 -DriveType 'SSD' -FreeDiskGB 10 -IsLaptop 1
Assert-Eq $Laptop.DisableHibernate $false 'Laptop keeps hibernate'

Write-Host "All Resolve-HardwareProfile assertions passed."
