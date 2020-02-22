
<#
This is a quick snippet I whipped up this morning to dynamically add functions your your PowerShell Jobs
without having to recreate the script block. There are two flavors, implicit or explicit. 
 Implicit will get all functions (that are not attached to a module) 
 Explicit: You define what functions you wish to pull.
#>

Function TestAnotherFunction(){
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $ParameterName
    )
    Write-Output $ParameterName
}

# Enumerate all the Functions that are not loaded from a module. This will include alias functions as well. 
$Functions = (Get-Item "Function:*").Where{$_.Source -eq "" -and $_.CommandType -eq "Function"} | ForEach-Object { [String]"Function $($_.Name) { $($_.ScriptBlock) };" }

# Select Specific Functions
$FunctionsToInclude = 'TestFunction','TestAnotherFunction'
$Functions = (Get-Item "Function:*").Where{$_.Name -in $FunctionsToInclude } | ForEach-Object { [String]"Function $($_.Name) { $($_.ScriptBlock) };" }

# Build out a scriptblock of the functions
$ScriptBlock = [scriptblock]::Create($Functions)

# Include into your PowerShell Job
$Job = Start-Job -InitializationScript $ScriptBlock -ScriptBlock { $output = TestAnotherFunction -ParameterName "TEST" ; Write-Output $output }