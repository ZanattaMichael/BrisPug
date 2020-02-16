

#
# Demo 1: Allow Null
#

# In this function allow null
function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        [Object]
        $ParameterName
    )
        
}
# Call the Function
Advanced-Function -ParameterName $null

# In this function let's remove the AllowNull Attribute
function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Object]
        $ParameterName
    )
        
}
# Call the Function
Advanced-Function -ParameterName $null

#
# Demo 2: Allow AllowEmptyString
#

# In this function allow empty String
function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [String]
        $ParameterName
    )
        
}
# Call the Function
Advanced-Function -ParameterName ""

# In this function let's remove the AllowEmptyString Attribute
function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $ParameterName
    )
        
}
# Call the Function
Advanced-Function -ParameterName ""

#
# Demo 2: Allow AllowEmptyCollection
#

# In this function allow an empty collection
function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [String[]]
        $ParameterName
    )
        
}
# Call the Function
Advanced-Function -ParameterName @()

# In this function let's remove the AllowEmptyCollection Attribute
function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]
        $ParameterName
    )
        
}
# Call the Function
Advanced-Function -ParameterName @()

#
# Demo 3: Validate Script
#
function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #
        # In this example we are validating the filepath of the parameter
        # Note that I am using $_ to reference the parameter value
        [ValidateScript({
            Test-Path -LiteralPath $_
        })]
        [String[]]
        $LiteralPath
    )
}

Advanced-Function -LiteralPath "C:\"
Advanced-Function -LiteralPath "C:\AAAAAAAAA"

#
# Demo 4: Using ValidateSet
#

function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #
        # In the Validate Set I include an array of acceptable values
        [ValidateSet('Michael','Tim','Peter')]
        [String]
        $Names
    )
}
# Now when we call the function you can see that the names will auto fill.
Advanced-Function -Names 

#
# Demo 5: Using ValidateCount
#

function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #
        # Let's Specify a Collection Minimum Count of 1 and a Maximum of 5
        [ValidateCount(1,5)]
        [String[]]
        $Names
    )
}
# Let's Provide 3 Items into the Parameter
Advanced-Function -Names "Michael", "Tim", "Alex"
# Let's now provide 6 items and watch it break!
Advanced-Function -Names "Michael", "Tim", "Alex", "David", "John", "Peter"

#
# Demo 5: Using ValidateLength
#

function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #
        # This will accept a char length from 1 to 5
        [ValidateLength(1,5)]
        [String[]]
        $Names
    )
}
# This will work
Advanced-Function -Names "12345"
# This will fail
Advanced-Function -Names "123456"

#
# Demo 6: Using Patten
#

function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #
        # The Parameter Name must match the following regular expression
        [ValidatePattern("[a-zA-Z+]")]
        [String[]]
        $Names
    )
}
# This will work
Advanced-Function -Names "MIchael"
# This will fail
Advanced-Function -Names "12345"

#
# Demo 6: Validating Range
#

function  Advanced-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #
        # The Integer must be within the following range
        [ValidateRange(-10,+10)]
        [Int]
        $XPos
    )
}
# This will work
Advanced-Function -XPos 0
Advanced-Function -XPos -10
Advanced-Function -XPos 10
# This will fail
Advanced-Function -XPos -11

#
# Demo 8: Validate Not Null
#

# In this function allow null
function  Advanced-Function {
    [CmdletBinding()]
    param (
        #
        # Note that this parameter is not mandatory.
        [ValidateNotNull()]
        [String[]]
        $ParameterName
    )
}

# Call the Function and parse $null 
Advanced-Function -ParameterName $null
# Call the Function and parse an parameter value
Advanced-Function -ParameterName "TEST"

#
# Let's remove ValidateNotNull
function  Advanced-Function {
    [CmdletBinding()]
    param (
        #
        # Note that this parameter is not mandatory.
        [String[]]
        $ParameterName
    )
}

# Call the Function and parse $null 
Advanced-Function -ParameterName $null