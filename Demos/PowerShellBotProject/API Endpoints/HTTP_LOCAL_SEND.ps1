<# POST method: $req
Statuses that will be used during execution
In Progress - Script has been sent to endpoint. Awaiting results.
Completed - Script has finished executing and results have been received. 
Failed - Script has finished executing or thrown an error. No results received. 

REQUEST:

$SendObj = @{

    ComputerName = "Test01"
    Code = "Base 64 encoded CliXML"

}

RESPONSE:

{
    "GUID":  "45f13471-9eea-4463-8b5d-96aa90e02de6",
    "Status":  "In Progress"
}

#>

#
# Functions to Load

#region Test-Property
# Function to test if a Property exists in an Object
# Author: Michael Zanatta
#----------------------------------------------------------------------------------------------------
function Test-ObjectProperty() {
    #------------------------------------------------------------------------------------------------
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [AllowNull()]
        [Object]
        $object,
        [parameter(Mandatory = $true, Position = 1)]
        [string[]]
        $property
    )

    $result = $true

    #
    # Use Get Member to Locate the Property. If the collection contains true then the property exists.
    # If not then it dosen't
    #

    forEach ($prop in $property) {
        try {
            # Return False if the Object is Null
            if ($object -eq $null) {
                $result = $false
            }
            # Validate the Object Type. If the object is a hashtable it will need to be handled differently.
            elseif ($object -is [System.Collections.Hashtable]) {
                # Process as a Dictionary Element
                if (-not($object.GetEnumerator().Name | Where-Object {$_ -eq $prop})) {
                    # Update the Result
                    $result = $false
                }
            } else {
                # Process as an PSObject
                if (-not($object | Get-Member -Name $prop -MemberType Properties, ParameterizedProperty)) {
                    # Update the Result
                    $result = $false
                }
            }
        } catch {
        }
    }

    Write-Output $result
}
#endregion Test-Property

#
# Get the Body of the HTML Request
$requestBody = Get-Content $req -Raw | ConvertFrom-Json

# Validate the Input
if (-not (Test-ObjectProperty -object $requestBody -property ComputerName, Code)){
    #This if statement will execute if test-objectproperty evaluates to be false
    

}

#
# Invoke SQL Query to Add to the Database
#

# Command Table

$GUID = [GUID]::NewGuid().GUID

# Return object. Contains information that will returned to the sender. 

$ReturnObj = @{

    GUID = $GUID
    Status = "In Progress"

}

#TODO-Future - Results Table

#Return the results to the sender. 

Return ($ReturnObj | ConvertTo-Json)