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