#
# http://www.google.com?key=value
# 1) Input
#    Send GUID to Server to request job
#    Declare the URI
# 2) Process
#    Invoke-RestMethod URI.GUID
#    Use Get cmdlet 
#    Validate response. What if error occurs. How to handle.
#    Receive an Object of information. Format response.
# 3) Output
#    Write-Output $_
#





#region Test-ObjectProperty
# Function to test if a Property exists in an Object
# Author: Michael Zanatta
#----------------------------------------------------------------------------------------------------
function Test-ObjectProperty() {
    #------------------------------------------------------------------------------------------------
    #------------------------------------------------------------------------------------------------
    param (
        [parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [Object]
        $object,
        [parameter(Mandatory, Position = 1)]
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
                # Process as a PS HashTable Element
                if (-not($object.GetEnumerator().Name | Where-Object {$_ -eq $prop})) {
                    # Update the Result
                    $result = $false
                }
            }
            elseif ($object.GetType().Name -like "*Dictionary*") {
                # Process as a Dictonary Element
                if (-not($object.Keys.Where{$_ -eq $prop})) {
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
#endregion Test-ObjectProperty



function ConvertTo-Base64 {
    <#
    
    .SYNOPSIS
    Converts a string to a Base64 String
    
    .DESCRIPTION
    Converts a string to a Base64 String
    
    .EXAMPLE
    "asdadasdasdasd" | ConvertTo-Base64
    
    .NOTES
    Example Output:
    
    (BASE64 String)YQBzAGQAYQBkAGEAcwBkAGEAcwBkAGEAcwBkAA==
                                                                                                                               
    .LINK
    https://au.linkedin.com/in/michael-zanatta-61670258
    
    #>
        [CmdletBinding()]
        Param (
        
            [parameter(
                ValueFromPipeline=$True,
                Mandatory=$true
            )]
            [String]$String
    
        )
    
        # 
        # This function converts a string into BASE64
        #
        begin {
    
     
            #
            # region Initalize code
            #
            Write-Verbose "[CMDLET] ConvertTo-Base64"
            Write-Verbose "{BEGIN} START"
            
            #
            # endregion Initalize code
            #       
    
        } 
    
        process {
            
            #
            # region Process code
            #
            Write-Verbose "{PROCESS} START"
            Write-Verbose "Converting String to BASE64. DUMP:"
            Write-Verbose "$String"
    
            $obj = [System.Convert]::ToBase64String(([System.Text.Encoding]::UTF8.GetBytes($String)))
    
            Write-Verbose "Converted to:"
            Write-Verbose $obj
            
            #
            # endregion Process code
            #
    
        }
    
        end {
    
            #
            # region Cleanup code
            #
            Write-Verbose "{END} START"
    
            return $obj
    
            #
            # endregion Cleanup code
            #
    
    
        }
    
    }
    
function ConvertFrom-Base64 {
<#

.SYNOPSIS
Converts a Base64 string to a normal String

.DESCRIPTION
Converts a Base64 string to a normal String

.EXAMPLE
"YQBzAGQAYQBkAGEAcwBkAGEAcwBkAGEAcwBkAA==" | ConvertTo-Base64

.NOTES
Example Output:

(BASE64 String)asdadasdasdasd
                                                                                                                            
.LINK
https://au.linkedin.com/in/michael-zanatta-61670258

#>

    [CmdletBinding()]
    Param (
    
        [parameter(
            ValueFromPipeline=$True,
            Mandatory=$true
        )]
        [String]$EncodedText

    )

    # 
    # This function converts a string into JSON from BASE64
    #
    begin {

        #
        # region Initalize code
        #
        Write-Verbose "[CMDLET] ConvertFrom-Base64"
        Write-Verbose "{BEGIN} START"
        
        #
        # endregion Initalize code
        #       
        

    } 

    process {

        #
        # region Process code
        #
        Write-Verbose "{PROCESS} START"
        Write-Verbose "Converting BASE64 to String. DUMP:"
        Write-Verbose "$EncodedText"

        # Set the Success to be False
        $Success = $false
        # Set a Counter
        $count = 1

        do {

            try {
                # Try Convert The Object
                $obj = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncodedText))
                # Set Success Flag
                $Success = $True
                # Break
                break
            } catch {
                # Add some padding and try again
                $EncodedText = "$EncodedText="
                $CaughtError = $_
            }

        } Until ($count++ -gt 2)

        # If the result failed, then throw a terminating error
        if (-not($Success)) {
            throw $CaughtError
        }

        Write-Verbose "Converted to:"
        Write-Verbose $obj
        
        #
        # endregion Process code
        #

    }

    end {

        #
        # region Cleanup code
        #
        Write-Verbose "{END} START"

        return $obj

        #
        # endregion Cleanup code
        #

    }

}


    <#
    Param (
        (
            [Parameter Attributes] [parameter(AttributeName = AttributeValue, AttributeName = AttributeValue)]
            [Paramter Validation]
            [Type]$ParameterName
        )   
    )        
    #>


#
# function NameOfFunction
function Get-PSRemoteJob {

    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [String]$GUID,
        [parameter(Mandatory = $true, Position = 2)]
        [String]$URI
    )

    #
    # Credit: Jordan Borean
    #

    $security_protocols = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::SystemDefault
    if ([Net.SecurityProtocolType].GetMember("Tls11").Count -gt 0) {
        $security_protocols = $security_protocols -bor [Net.SecurityProtocolType]::Tls11
    }
    if ([Net.SecurityProtocolType].GetMember("Tls12").Count -gt 0) {
        $security_protocols = $security_protocols -bor [Net.SecurityProtocolType]::Tls12
    }
    [Net.ServicePointManager]::SecurityProtocol = $security_protocols

    #
    # Parameter Block that is used to be send to the Auzre Function.

    $Param = @{
        #ContentType = "application/json"
        Method = "GET"
        Uri = "{0}?GUID={1}" -f $URI, $GUID
    }

    #
    # Try Invoke the Rest Query

    try {
        # Invoke the Rest Method
        $result = Invoke-RestMethod @Param
        # Format the Response

        # Test for the $result.success.status property. If the property dosen't exist, then write "No Response"
        if (-not(Test-ObjectProperty -object $result.Success -property Status)) {

            # Write output
            Write-Output ([PSCustomObject]@{Response = "No Response"})

        } elseif ($result.Success.Status -eq "Completed") {
            [PSCustomObject]$result.Success.Output = $(
                if ($result.Success.Output -ne $null) {
                    # Format the output.
                    # Output is encoded in BASE64 & Serialized as JSON
                    Write-Output ($result.Success.Output | ConvertFrom-Base64 | ConvertFrom-Json)
                } else {
                    Write-Output ([PSCustomObject]@{Response = "No Response"})
                }
            )
        }


    } catch {
        Write-Error $_
        
    }
    
    Write-Output $result
    
}

#https://brispug-remotebot.azurewebsites.net/api/HTTP_LOCAL_SEND?code=hu4w1CgSJKTIoQ4UgdXPcj7nLcmDc7pKd4bnFBRxZMndstXCQ1FUvg==
