#
# Basic Function Definition

Function BasicFunction {

    # Some Code within Here
    Write-Output "Hello World!"

}
# Call the Function
BasicFunction

Function BasicFunction() {

    # Some Code within Here
    Write-Output "Hello World!"

}
# Call the Function
BasicFunction

Function BasicFunction($Param1) {

    # Some Code within Here
    Write-Output $Param1

}
# Call the Function with the Optional Parameter
BasicFunction "Hello World"
# Use Parameter Name
BasicFunction -Param1 "Hello World"

Function BasicFunction{
    Param($Param1)

    Write-Output $Param1
}
BasicFunction -Param1 "Hello World"
# Use Parameter Name
BasicFunction -Param1 "This is me"

#
# PowerShell Scopes
#

# Rule Number 1: Scopes can nest.

$Var = "Parent Scope"
Function PowerShellChildScope {
    $var = "Child Scope"
}

Function PowerShellChildScope {
    $var = "Child Scope"

    Function PowerShellChildScope {
        $var = "Nested Child Scope"
    }

}

# This Applies ScriptBlocks {}

# Show Function Scope Accessing Parent Scope
# Rule Number: 2 - Items will cascade into child scopes, unless set to Private
$Var = "Never Gonna Give you Up"

Function PowerShellScopeDemo {
    Write-Output $Var
}

# Show Function Changing Child Scope
# Show Rule Number 3 - Items changed within the scope, change where they were created 
$Var = "Never Gonna Give you Up"

Function PowerShellScopeDemo {
    $Var = "Never Gonna Let You Down"
    Write-Output $Var
}

$Var

# Show Function Scope Accessing Parent Scope (When Set to Private)

$Private:Var2 = "Never Gonna Let You Down"

Function PowerShellScopeDemo {
    Write-Output $Var2
}

# Show Creating Local Scoped Variable (with the Same Name as the Parent Scope)

$Private:Var2 = "Never Gonna Let You Down"
Write-Output $Var2

Function PowerShellScopeDemo {
    $var2 = "This is a local variable"
    Write-Output $var2
}


# Let's set the Script Scope - Comment out lines above
$Script:Var = "This is a Script Variable"
Write-Host "Inside Script Execution: $Var"
# Stop Script
# Run $Var

#return


# Let's set the Script Scope - Comment out lines above
$Global:Var = "This is a Global Variable"
Write-Host "Inside Script Execution: $Var"
# Stop Script
# Run $Var

#return

#
# Let's set a scoped variable and mess with it

$Script:Var = "Outside the Script"
# Print the Intitial Variable
Write-Host "$Var"
Function BasicFunction {
    # Update the Variable
    $Script:Var = "Inside the Variable"
}
# Call the Function
BasicFunction
# Print the Updated Variable
Write-Host "$Var"

# Change the Scope without using $Script or $Global
$var = "Test"
Function ReturnWithoutChangingScope {
    Write-Output "Changed"
}
$var = ReturnWithoutChangingScope

#
# Let's set the scope of a function.

Function Global:BasicFunction {
    Write-Output "I am a global function"
}