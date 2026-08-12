Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Remove-ItemPropertyVerified() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Path,
        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Name,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Include,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Exclude,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch]   $Force
    )

    Begin {
        $Script:TweakType = "Exp/Reg"
    }

    Process {
        ForEach ($DirectoryPath in $Path) {
            If (Test-Path "$DirectoryPath") {
                $ItemProps = (Get-Item -Path "$DirectoryPath").Property
                ForEach ($NameParam in $Name) {
                    If ($ItemProps -ccontains $NameParam) {
                        Write-Status -Types "-", $TweakType -Status "Removing: `"$DirectoryPath>$NameParam`""
                        Try {
                            $Splat = @{
                                Path        = $DirectoryPath
                                Name        = $NameParam
                                Force       = $Force
                                ErrorAction = 'Stop'
                            }
                            If ($Include) { $Splat['Include'] = $Include }
                            If ($Exclude) { $Splat['Exclude'] = $Exclude }
                            Remove-ItemProperty @Splat
                        } Catch {
                            Write-Status -Types "?", $TweakType -Status "Failed to remove `"$DirectoryPath>$NameParam`": $_" -Warning
                        }
                    } Else {
                        Write-Status -Types "?", $TweakType -Status "The property `"$DirectoryPath>$NameParam`" does not exist." -Warning
                    }
                }
            } Else {
                Write-Status -Types "?", $TweakType -Status "The path `"$DirectoryPath`" couldn't be found." -Warning
            }
        }
    }
}
