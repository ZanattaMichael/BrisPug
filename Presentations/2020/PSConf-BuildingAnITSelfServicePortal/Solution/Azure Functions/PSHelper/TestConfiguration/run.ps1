using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Deseralize the JSON
$RequestBody = $Request.Body
#
# Load the DLL

# Get Current Script Location
$Location = Get-Location
$AssemblyPath = [System.IO.Path]::Combine($Location.Path,"DLLs","ConfigurationBuilderCore.dll")

# Load the Assembly
Add-Type -LiteralPath $AssemblyPath

# Build the Configuration
$AddedConfiguration = [System.Collections.Generic.List[ConfigurationBuilder.HTMLObject]]::New()
$Path = [System.IO.Path]::Combine($Location.Path, "Configurations")
$Files = Get-ChildItem -LiteralPath $Path -Filter *.ps1

# Set the Status to be OK
$Status = [HttpStatusCode]::OK
$ResponseBody = @{ success = "validated" }

# Counter
$i = 0

# Build the Configuration 
ForEach ($File in $Files) {

    try {
        # Dot Source the Items in.
        $Configuration = . $File.FullName
        # Compile
        $HTMLObject = [ConfigurationBuilder.HTMLObject]::Add($Configuration.RunbookPSObject,
                                                            $Configuration.RestBody, 
                                                            $Configuration.HTMLContent,
                                                            $i++)

        $null = $AddedConfiguration.Add($HTMLObject)
    } catch {

        Write-Error $_

        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::ExpectationFailed
            Body = @{ error = $_ } | ConvertTo-Json 
        })
        return;
    }

}
# Ensure that a configuration item was returned. If not throw an error.
if ($AddedConfiguration.Count -eq 0) {
    Write-Error "No Configuration was Loaded. Stopping."
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::ExpectationFailed
        Body = @{ error = "No configuration was Loaded" } | ConvertTo-Json
    })
    return;
}

#
# Validate the Body of the Request according to the Configuration

$Properties = 'Identity','Type','HTMLNameSelected','HTTPResponseBodyParameters'

# Test Properties Exist
if ($RequestBody.Keys.Where{$_ -notin $Properties}) { 
    Write-Error "Missing 'Identity','Type','HTMLNameSelected','HTTPResponseBodyParameters' Parameters. Stopping."
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::ExpectationFailed
        Body = @{ error = "Missing Paramters" } | ConvertTo-Json
    })
    return;
}

#
# Match the Type with the Configuration



$ConfigItem = $AddedConfiguration.Where{$_.httpContent.Type -eq $RequestBody.Type}

# Ensure that only a single configuration item was returned.
if ($ConfigItem.Count -ne 1) {

    Write-Warning ("Could not match 'Type' ({0}) from Request Body with loaded configuration" -f $RequestBody.Type)    
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        Status = [HttpStatusCode]::NotFound
        Body = @{ error = ("Could not match 'Type' ({0}) from Request Body with loaded configuration" -f $RequestBody.Type) } | ConvertTo-Json
    }) 
    return;
}

#
# The Configuration is Matched. Validate the Runbook Parameters are Valid

# Match the Configuration Paramters to the Runbook Parameter
ForEach ($ConfigurationParameter in $ConfigItem.AzureAutomationRunbook.Parameters) {
    if ($RequestBody.HTTPResponseBodyParameters.Name -notcontains $ConfigurationParameter.Name) {
        Write-Warning ("Could not match 'RunbookParamterName' ({0}) from Request Body with the loaded configuration" -f $RequestBody.Type)
        $Status = [HttpStatusCode]::NotFound
        $ResponseBody = @{ error = "Could not match 'RunbookParamterName' from Request Body with the loaded configuration" }
    }
}
# Match the Runbook Parameter to the Configuration Parameter
ForEach ($RunbookParameter in $RequestBody.HTTPResponseBodyParameters) {
    if ($ConfigItem.AzureAutomationRunbook.Parameters.Name -notcontains $RunbookParameter.Name) {
        Write-Warning ("Could not match 'RunbookParamterName' ({0}) from Request Body with the loaded configuration" -f $RequestBody.Type)
        $Status = [HttpStatusCode]::NotFound  
        $ResponseBody = @{ error = "Could not match 'RunbookParamterName' from Request Body with the loaded configuration" }
    }
}

#
# Match the Input

# Iterate through each of the runbook parameters within the configuration and match the values for a (SELECT) is correct:
# This prevents users from adjusting the local configuration and sending malformed data.

ForEach ($Parameter in $RequestBody.HTTPResponseBodyParameters) {

    try {
        # Match the Parameter Name
        $matchedParameterName = $ConfigItem.AzureAutomationRunbook.Parameters.Where{$_.Name -eq $Parameter.Name}

        # Fetch the Corresponding HTML Configuration Item
        $HTMLConfiguration = $ConfigItem.httpContent.HTMLConfigs.Where{$_.HTMLName -eq $matchedParameterName.HTMLName}
        
        # If the tag is null Throw an Error
        if ($null -eq $HTMLConfiguration.ElementType) {
            Throw "Configuration Error. Cannot get ElementType."
        } elseif ($HTMLConfiguration.ElementType -ne "SELECT") {
            # Skip all tags that are not are a 'SELECT'
            continue;
        }
        
        # Perform a Lookup on the Value and Ensure that the Value is matched in the presented list.
        # Otherwise malformed data has been detected.
        if ($HTMLConfiguration.Values -notcontains $Parameter.Value) {
            Write-Warning ('Malformed Data Detected. Could not match {0} to Loaded Configuration' -f $Parameter.Value)
            $Status = [HttpStatusCode]::BadRequest
            $ResponseBody = @{ error = ('Malformed Data Detected. Could not match ({0}) to the Loaded Configuration' -f $Parameter.Value) }
        }

    } catch {
       # Write-Error $_
        $Status = [HttpStatusCode]::BadRequest
        $ResponseBody = @{ error = ('An error occured attempting to validate the loaded configuration.') }        
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $Status
    Body = $ResponseBody | ConvertTo-Json
})
