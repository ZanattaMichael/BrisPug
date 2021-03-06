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