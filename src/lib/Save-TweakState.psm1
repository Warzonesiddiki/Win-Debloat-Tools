Import-Module -DisableNameChecking "$PSScriptRoot\Title-Templates.psm1"

function Get-TweakStateDirectory {
    [CmdletBinding()]
    [OutputType([String])]
    param ()

    $Directory = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Win-Debloat-Tools"
    If (!(Test-Path -LiteralPath $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    return $Directory
}

function Get-TweakStatePath {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String] $Name = "tweak-state.json"
    )

    return (Join-Path -Path (Get-TweakStateDirectory) -ChildPath $Name)
}

function Read-TweakState {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param (
        [String] $Name = "tweak-state.json"
    )

    $Path = Get-TweakStatePath -Name $Name
    If (!(Test-Path -LiteralPath $Path)) {
        return @{}
    }

    Try {
        $Raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        If ([String]::IsNullOrWhiteSpace($Raw)) { return @{} }
        return @{ State = ($Raw | ConvertFrom-Json) }
    } Catch {
        Write-Status -Types "?", "State" -Status "Could not read tweak state '$Path': $_" -Warning
        return @{}
    }
}

function Write-TweakState {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $InputObject,
        [String] $Name = "tweak-state.json"
    )

    $Path = Get-TweakStatePath -Name $Name
    Try {
        $InputObject | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8
        Write-Status -Types "+", "State" -Status "Saved tweak state to $Path"
    } Catch {
        Write-Status -Types "?", "State" -Status "Could not save tweak state '$Path': $_" -Warning
    }
}
