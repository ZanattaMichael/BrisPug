#
# CmdletBinding

# Adds -Verbose and -Debug Switches
function AdvancedFunction {
    [Cmdletbinding()] 
    Param($Param1)

    Write-Verbose "Hello Verbose"
    Write-Debug "Write Debug"
}

#
# Confirm Impact

# Let's take a look at the $ConfirmPreference Automatice Variable
$ConfirmPreference

function AdvancedFunction {
    [Cmdletbinding(
            ConfirmImpact="Medium",
            SupportsShouldProcess=$true
    )] 
    Param($Param1)

    # Should Process has the following Overloads:

    <#
     ShouldProcess([String]verboseDescription, [String]verboseWarning, [String]caption, [ShouldProcessReason]shouldProcessReason) 
     ShouldProcess([String]verboseDescription, [String]verboseWarning, [String]caption) 
     ShouldProcess([String]target, [String]action)  
     ShouldProcess([String]target)

     target = Name of the target resource being acted upon. This will potentially be displayed to the user.
     action = Name of the action which is being performed. This will potentially be displayed to the user. (default is Cmdlet name)
     verboseDescription = Textual description of the action to be performed. This is what will be displayed to the user for ActionPreference.Continue.
     verboseWarning = Textual query of whether the action should be performed, usually in the form of a question. This is what will be displayed to the user for ActionPreference.Inquire.
     caption = Caption of the window which may be displayed if the user is prompted whether or not to perform the action. caption may be displayed by some hosts, but not all.
     shouldProcessReason = Indicates the reason(s) why ShouldProcess returned what it returned. Only the reasons enumerated in ShouldProcessReason are returned.
        ShouldProcessReason Enum
        None 0 - None of the Reasons Below
        WhatIf 1 - WhatIf was requested
    #>
    
    # This method returns $true or $false
    $ShouldProcessOutput = $PSCmdlet.ShouldProcess("ComputerName", "Display Write Host")
    
    # Overload 3
    if ($PSCmdlet.ShouldProcess("ComputerName", "Display Write Host")) {
        Write-Host "Overload 3"
    }

    # Overload 4
    if ($PSCmdlet.ShouldProcess("ComputerName")) {
        Write-Host "Overload 4"
    }

    Write-Verbose "Hello Verbose"
    Write-Debug "Write Debug"
}

# Call the Function
AdvancedFunction 

# Let's call the function using -WhatIf. Note that the action is not performed
AdvancedFunction -WhatIf
# Note that there was not prompt
# Let's lower the confirm preference to force a prompt
$ConfirmPreference = "Low"
# We now get the prompts since the parent preference is lower then the parameter, creating a prompt
AdvancedFunction
# Let's forcibly supress the confirmation
AdvancedFunction -Confirm:$false

#
#
#