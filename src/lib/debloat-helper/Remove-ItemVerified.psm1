Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Remove-ItemVerified() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Path,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Include,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Exclude,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch]   $Recurse,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch]   $Force
    )

    Begin {
        $Script:TweakType = "Exp/Reg"
    }

    Process {
        ForEach ($PathParam in $Path) {
            If (Test-Path -Path "$PathParam") {
                Write-Status -Types "-", $TweakType -Status "Removing: '$PathParam'"
                Try {
                    $Splat = @{
                        Path        = $PathParam
                        Recurse     = $Recurse
                        Force       = $Force
                        ErrorAction = 'Stop'
                    }
                    If ($Include) { $Splat['Include'] = $Include }
                    If ($Exclude) { $Splat['Exclude'] = $Exclude }
                    Remove-Item @Splat
                } Catch {
                    Write-Status -Types "?", $TweakType -Status "Failed to remove '$PathParam': $_" -Warning
                }
            } Else {
                Write-Status -Types "?", $TweakType -Status "The path `"$PathParam`" does not exist." -Warning
            }
        }
    }
}
