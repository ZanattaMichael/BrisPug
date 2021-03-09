using namespace System.Net


# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$Body = $Request.Body
Write-host $Request.Body
$name = $Body.Name

write-host "---NAME: $name"

$body = @{ response = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."}

if ($name) {
    $body = @{ response = "Hello, $name. This HTTP triggered function executed successfully." }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})