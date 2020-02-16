
Function AdvancedFunction {

    [cmdletbinding(
        DefaultParameterSetName = 'Other'
    )]
    # Ignore the Parameters below for the time being.
    param (
        [parameter(ParameterSetName = 'Standard')]
        [parameter(ParameterSetName = 'Other')]
        [String]
        $Param1,

        [parameter(ParameterSetName = 'Standard')]
        [String]
        $Param2,

        [parameter(ParameterSetName = 'Other')]
        [String]
        $Param3        
    )

    # Get the current ParameterSet Name by calling $PSCmdlet
    Write-Output $PSCmdlet.ParameterSetName

}

# This function has two parametersets.
# The first is -Param1 -Param2
# The second is -Param1 -Param3
# Note when calling the function we default the parameter set

# Let's call Advanced with a single parameter
AdvancedFunction -Param1 "A"
# It prints out "Other". This is the default parameterset name
# since powershell is not sure what parameter to use.

# We can also see the parameter set name
# Call using the first parameter set
AdvancedFunction -Param1 "A" -Param2 "A"
# Call using the second parameter set
AdvancedFunction -Param1 "A" -Param3 "A" 
# Call using all the parameters.
AdvancedFunction -Param1 "A" -Param2 "A" -Param3 "A" 
