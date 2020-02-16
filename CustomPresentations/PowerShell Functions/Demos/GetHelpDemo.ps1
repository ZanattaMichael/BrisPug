
#
# Let's Put this After the Declation of the Function.
#

function Test-Function {
<#
.SYNOPSIS
This is script that tests a function.

.DESCRIPTION
Test script, written by Michael tests test a function. Not Really. :-D

.EXAMPLE
    Test-Function

    This is the default execution
    
.EXAMPLE

    Test-Function -ParameterName "ITEM"

    This is another execution path.

.PARAMETER ParameterName

    ParameterName is not really used for anything. This is just a demo.

#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $ParameterName
    )

}


#
# Let's Put this Before the Declation of the Function.
#

<#
.SYNOPSIS
This is script that tests a function. (Demo Number 2)

.DESCRIPTION
Test script, written by Michael tests test a function. Not Really. :-D (Demo Number 2)

.EXAMPLE
    Test-Function2

    This is the default execution
    
.EXAMPLE

    Test-Function2 -ParameterName "ITEM"

    This is another execution path.

.PARAMETER ParameterName

    ParameterName is not really used for anything. This is just a demo.

#>
function Test-Function2 {

    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $ParameterName
    )

}


#
# Demo 3: Declare it at the end of the function
#


function Test-Function3 {

    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $ParameterName
    )

    <#
    .SYNOPSIS
    This is script that tests a function. (Demo Number 3)

    .DESCRIPTION
    Test script, written by Michael tests test a function. Not Really. :-D (Demo Number 3)

    .EXAMPLE
        Test-Function3

        This is the default execution
        
    .EXAMPLE

        Test-Function3 -ParameterName "ITEM"

        This is another execution path.

    .PARAMETER ParameterName

        ParameterName is not really used for anything. This is just a demo.

    #>
}