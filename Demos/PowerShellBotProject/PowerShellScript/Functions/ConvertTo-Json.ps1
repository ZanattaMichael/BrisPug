
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
