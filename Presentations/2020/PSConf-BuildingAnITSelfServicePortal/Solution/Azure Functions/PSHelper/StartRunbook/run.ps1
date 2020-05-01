using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$RequestBody = $(
    if ($Request.Body.GetType().Name -eq "String") {
        Write-Host "Request Body is Type String. Deseralizing:"
        $Request.Body | ConvertFrom-Json
    } else {
        $Request.Body
    }
)

$GetParams = @{
    ResourceGroupName = $RequestBody.ResourceGroupName
    AutomationAccountName = $RequestBody.AutomationAccountName
    Name = $RequestBody.Name
}

#
# Perform a Lookup of the Runbook

try {
    $runbook = Get-AzAutomationRunbook @GetParams
    if ($null -eq $runbook) { Throw "Missing Runbook Name: '$($GetParams.Name)'"}
} catch {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::NotFound
        Body = @{ error = "'$($GetParams.Name)' could not be found."}
    })
    return
}

#
# Construct the Runbook Parameters

$StartRunbookParams = @{
    Name = $runbook.Name
    RunOn = $RequestBody.RunOn
    AutomationAccountName = $RequestBody.AutomationAccountName
    ResourceGroupName = $RequestBody.ResourceGroupName
    # This is needed due to function app not converting nested objects to
    # to be Case-Insensitive (Refer to Gotchas)
    Parameters = [HashTable]::new($RequestBody.Parameters, [System.StringComparer]::OrdinalIgnoreCase)
}

#
# Start the Runbook
try {
    # Log Runbook Parameters
    Write-Host ("Starting Runbook with Parameters: {0}" -f ($StartRunbookParams | ConvertTo-Json))
    $Body = Start-AzAutomationRunbook @StartRunbookParams
    $StatusCode = [HttpStatusCode]::OK
} Catch {
    $StatusCode = [HttpStatusCode]::NotFound
    $Body = @{ error = "'$($GetParams.Name)' could not be found."}    
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $StatusCode
    Body = $Body
})
