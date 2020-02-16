#
# Using the Parameter Attributes
#

#
# Demo 1: Mandatory Parameter
Function Advanced-Function {
    [CmdletBinding()]
    param (
        #
        # Mandatory Parameter
        [Parameter(Mandatory=$true)]
        [String]
        $Parameter1,
        #
        # By specifying the argument, its implicitly $true
        [Parameter(Mandatory)]
        [String]
        $Parameter2,
        #
        # A Non-Mandatory Parameter
        [Parameter(Mandatory=$false)]
        [String]
        $Parameter3,
        #
        # It's better to leave the Mandatory Parameter
        # if it's not required. It's easier to read
        [Parameter()]
        [String]
        $Parameter4      
    )

    return $null
    
}

# Show the Different Ways you can Specify a Mandatory Parameter
Advanced-Function

#
# Demo 2: Parameter Set Name
#

Function Advanced-Function {
    [CmdletBinding(DefaultParameterSetName="Set1")]
    param (
        #
        # Both ParameterName and Computername
        # belong to different to different parameter sets
        # This means when calling this function
        # you can have one or the other.
        [Parameter(ParameterSetName="Set1")]
        [String]
        $ParameterName,
        [Parameter(ParameterSetName="Set2")]
        [String]
        $ComputerName      
    )

    return $PSCmdlet.ParameterSetName
}

# Call the Function
Advanced-Function -ParameterName "A"
Advanced-Function -ComputerName "A"
Advanced-Function -ParameterName "A" -ComputerName "A"


Function Advanced-Function {
    [CmdletBinding(DefaultParameterSetName="Set1")]
    param (
        #
        # Same function as before however we have added another 
        # parameter.
        [Parameter(ParameterSetName="Set1")]
        [String]
        $ParameterName,
        [Parameter(ParameterSetName="Set2")]
        [String]
        $ComputerName,
        #
        # Note that there are two parameter attributes
        # declared below. This allows this paramter to be
        # called by BOTH parameter sets.
        # You can stack (indefinitly) paramter attributes for different
        # Parameter set names.
        # Since they are different you can assaign different 
        # Arguments to the Attribute. Note the second one
        # is mandatory. This means that when using that set, the parameter is
        # mandatory. However if using the other one, it's optional.
        [Parameter(ParameterSetName="Set1")]
        [Parameter(ParameterSetName="Set2", Mandatory)]
        [String]
        $OtherString              
    )
    return $PSCmdlet.ParameterSetName
}

# Parameter Set 1
Advanced-Function -ParameterName "A" -OtherString "A"
# Parameter Set 1
Advanced-Function -ParameterName "A"
# Parameter Set 2
# Note that -OtherStirng is Mandatory
Advanced-Function -ComputerName "A"

#
# Demo Number 3: Position of the Cmdlets
#
Function Advanced-Function {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Position=0)]
        [String]
        $FirstParameter,
        [Parameter(Position=1)]
        [String]
        $SecondParameter,
        [Parameter(Position=2)]
        [String]
        $ThirdParameter
    )
    Write-Output $null
}

Advanced-Function -FirstParameter "A" -SecondParameter "B" -ThirdParameter "C"
Advanced-Function 1 2 3

#
# Demo Number: 4 Value from Pipeline
#

Function Advanced-Function {
    [CmdletBinding()]
    param (
        #
        # Accept the Entire Object        
        [Parameter(ValueFromPipeline)]
        [String[]]
        $ParameterName
    )

    Begin {
        
    }

    Process {
        # Access the Current Object in the Pipeline and Pass it in
        Write-Host $_
    }

    End {

    }
}

1,2,3,4,5,6 | Advanced-Function
Get-Process | Advanced-Function

#
# Demo Number: 5 Value from ValueFromPipelineByPropertyName
#

Function Advanced-Function {
    [CmdletBinding()]
    param (
        #
        # Accept the Entire Object        
        [Parameter(ValueFromPipelineByPropertyName)]
        [Int[]]
        $Id
    )

    Begin {
        
    }

    Process {
        # Access the Current Object in the Pipeline and Pass it in
        Write-Host $Id
    }

    End {

    }
}

# Let's pass the previous items in. Note that it dosen't work
1,2,3,4,5,6 | Advanced-Function
# Let create a collection some properties with 'id' in it.
$Collection = @(
    [PSCustomObject]@{
        Name = "Value"
        Id = 1
    },
    [PSCustomObject]@{
        Name = "Value2"
        Id = 2
    },
    [PSCustomObject]@{
        Name = "Value2"
        Id = 3
    }
)
# Pass Collection in
$Collection | Advanced-Function

#
# Let's Create A Second Parameter Called Name
#
Function Advanced-Function {
    [CmdletBinding()]
    param (
        #
        # Accept Only the ID Property      
        [Parameter(ValueFromPipelineByPropertyName)]
        [Int[]]
        $Id,
        #
        # Accept Only the Name Property      
        [Parameter(ValueFromPipelineByPropertyName)]
        [String[]]
        $Name        
    )

    Begin {
        
    }

    Process {
        # Access the Current Object in the Pipeline and Pass it in
        Write-Host $Id, $Name
    }

    End {

    }
}

# 
# Let's Pass the Collection back in
$Collection | Advanced-Function

#
# Demo Number: 6 -> Help Function
# Demo in PowerShell 6.2.3
#

function Advanced-Function  {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage="Enter in the ComputerName. Use '.' for the local machine.")]
        [String]
        $ComputerName
    )
}

# Call Advanced Function
Advanced-Function
# Press !? for help message