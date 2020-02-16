
#
# Demo 1: Let's explore the Definition
#

Function Advanced-Function {
    param (
        [TypeName]
        $ParameterName
    )
}

#
# Demo 2: Let's Create Custom Type Name - String
#

Function Advanced-Function {
    param (
        [String]
        $ParameterName
    )

    $ParameterName.GetType().Name

}
Advanced-Function -ParameterName "Hello World!"

#
# Demo 3: Let's Create Custom Type Name - Integer
#

Function Advanced-Function {
    param (
        [Int]
        $ParameterName
    )

    $ParameterName.GetType().Name

}

# Let's call it
Advanced-Function -ParameterName 1
# Now let's parse an array into it and see what happens
Advanced-Function -ParameterName 1,2,3,4

#
# Demo 4: Let's Create an Array Type by declaring [Int[]]
#
Function Advanced-Function {
    param (
        [Int[]]
        $ParameterName
    )

    $ParameterName.GetType().Name

}

# Let's parse an array of int's in
Advanced-Function -ParameterName 1,2,3,4

#
# Demo 5: Switch vs Booleen
#

# Take the following booleen example:
Function Advanced-Function {
    param (
        [Bool]
        $ParameterName
    )

    $ParameterName

}

# Let's call it:
Advanced-Function -ParameterName $false
Advanced-Function -ParameterName $true
Advanced-Function
# Note that we will to explicitly specify $false or $true if calling it.

# Let's now use a switch
Function Advanced-Function {
    param (
        [Switch]
        $ParameterName
    )

    $ParameterName

}

# Let's call it again using switches
Advanced-Function
Advanced-Function -ParameterName

#
# Note that we can get the same result as the [Bool] but we can exclude the $true, $false and let PowerShell do it for us.