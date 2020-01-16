using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Pull the SQL Password
#Wait-Debugger

$SQLPassword = (Get-AzKeyVaultSecret -VaultName BrisPug -Name brispugbotdemo).SecretValue

# Let's Create a Secure String :-D

#$TestSecureString = "Testing123" | ConvertTo-SecureString -AsPlainText -Force

#$string = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000009cbb6d7ca83ac044b8943efa8f42406a00000000020000000000106600000001000020000000b739e3d4725e84e7e6ba29ec61859f85801225cb0251c1660044c3f1918476f1000000000e80000000020000200000003c414018ff4ed7803209e80c91fdec757276c523588b7116b5d84ccfddbb40162000000028ff0a3ab2ff8df5d0e15f0ff109c4dd93786a3d601728bc91f916e3a40bd19240000000821660128fc1d013a0fda8c2c1f0035a21471d652e4af07f3698a873b38062000513e43f6cb5f014c8073b278f57e4e87bbdfd7b044b234872d1595b73563758"
#$ss = $string | ConvertTo-SecureString

# Write to the Azure Functions log stream.
#Write-Host "PowerShell HTTP trigger function processed a request."

($Request | ConvertTo-Json | Out-File -LiteralPath C:\temp\object.txt)

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

if ($name) {
    $status = [HttpStatusCode]::OK
    $body = "Hello $name"
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = "Please pass a name on the query string or in the request body."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
