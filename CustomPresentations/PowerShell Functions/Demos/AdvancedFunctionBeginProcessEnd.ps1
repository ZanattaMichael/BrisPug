
<#
#
# Demo 1: Show Optional Begin and End Blocks
#
Function AdvancedFunction {
    [cmdletbinding(
        DefaultParameterSetName = 'Standard'
    )]
    # Ignore the Parameters below for the time being.
    param (
        [parameter(ParameterSetName = 'Standard', ValueFromPipeline)]
        [parameter(ParameterSetName = 'Other', ValueFromPipeline)]
        [String]
        $Param1,

        [parameter(ParameterSetName = 'Standard')]
        [String]
        $Param2,

        [parameter(ParameterSetName = 'Other')]
        [String]
        $Param3        
    )


    Process {
        Write-Host "Executed Each Time for each object in the pipeline"
        #Write-Host "Let's use $_ to reference the current item. Uncomment Me"
    }


}
#
# Show that the Process Block is mandatory and the others are optional
"TEST" | AdvancedFunction
# Let's Look at ForEach-Object
"TEST" | ForEach-Object -Begin -Process -End
"TEST" | ForEach-Object { $_ }
#>

Function AdvancedFunction {
    [cmdletbinding(
        DefaultParameterSetName = 'Standard'
    )]
    # Ignore the Parameters below for the time being.
    param (
        [parameter(ParameterSetName = 'Standard', ValueFromPipeline)]
        [parameter(ParameterSetName = 'Other', ValueFromPipeline)]
        [String[]]
        $Param1,

        [parameter(ParameterSetName = 'Standard')]
        [String]
        $Param2,

        [parameter(ParameterSetName = 'Other')]
        [String]
        $Param3        
    )

    Begin {
        Write-Host "Executed Begin Block Once"
        #Write-Host "Let's try and access parameters. Put a breakpoint on me."
        
    }
    Process {
        Write-Host "Executed Each Time for each object in the pipeline"
        #Write-Host "Let's use $_ to reference the current item. Uncomment Me"
    }
    End {
        Write-Host "Executed End Block Once"
    }

}

# Let's invoke the function
# Place a Breakpoint on "Let's try and access parameters"
# Uncomment "Let's use $_"
# 1,2,3,4 | AdvancedFunction

AdvancedFunction -Param1 1,2,3,4
