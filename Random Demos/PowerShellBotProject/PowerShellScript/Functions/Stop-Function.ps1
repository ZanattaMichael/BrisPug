# region Stop-Function 
# Function to stop the script (Terminating)
# Authors: Michael Zanatta, Christian Coventry

function Stop-Function() {
    # Parameters
    param(
        [parameter(Mandatory, Position = 0)]
        [String]
        $ErrorMessage,
        [parameter(Position = 1)]
        [System.Management.Automation.ErrorRecord]
        $Trace

    )
    
    # Test if Trace Parameter Exists
    if ($Trace -ne $null) {

        # Update the TraceLog with Error
        Get-Error $Trace

    }

    # Send a HTTP Response
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = @{error = $ErrorMessage}
    })
    
}


#
# Tests
#
# 
