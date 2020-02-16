#
# Demo 1: Specify Default Value
#

function Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        # Let's Default Value
        $ParameterName="TEST"
    )

    Write-Host $ParameterName

}

# Standard Execution
Advanced-Function -ParameterName "Hello World!"
# Let's go ahead an use the default value
Advanced-Function