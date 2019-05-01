



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
function Start-PSRemoteJob {

    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [String]$ComputerName,
        [parameter(Mandatory = $true, Position = 1)]
        [ScriptBlock]$PowerShellScript,
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
        ContentType = "application/json"
        Method = "POST"
        Uri = $URI
        Body = @{
            ComputerName = $ComputerName
            Code = $PowerShellScript | ConvertTo-Base64
        } | ConvertTo-JSON
    }

    #
    # Try Invoke the Rest Query

    try {
        # Invoke the Rest Method
        $result = Invoke-RestMethod @Param
    
    } catch {
        Write-Error $_
    }
    
    Write-Output $result
    
}

#https://brispug-remotebot.azurewebsites.net/api/HTTP_LOCAL_SEND?code=hu4w1CgSJKTIoQ4UgdXPcj7nLcmDc7pKd4bnFBRxZMndstXCQ1FUvg==
