Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Set-ItemPropertyVerified() {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Path,
        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]   $Name,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet('Binary', 'DWord', 'ExpandString', 'MultiString', 'None', 'QWord', 'String', 'Unknown')]
        [String]   $Type,
        [Parameter(Position = 2, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $Value <# Will have dynamic typing #>
    )

    Begin {
        $Script:TweakType = "Registry"
    }

    Process {
        ForEach ($PathParam in $Path) {
            If (!(Test-Path "$PathParam")) {
                Write-Status -Types "?", $TweakType -Status "Creating new path in `"$PathParam`"..." -Warning
                New-Item -Path "$PathParam" -Force | Out-Null
            }

            Try {
                $Splat = @{
                    Path        = $PathParam
                    Name        = $Name
                    Value       = $Value
                    Force       = $true
                    ErrorAction = 'Stop'
                }
                If ($Type) {
                    $Splat['Type'] = $Type
                }
                Set-ItemProperty @Splat
            } Catch {
                Write-Status -Types "?", $TweakType -Status "Failed to set property `"$PathParam>$Name`": $_" -Warning
            }
        }
    }
}
