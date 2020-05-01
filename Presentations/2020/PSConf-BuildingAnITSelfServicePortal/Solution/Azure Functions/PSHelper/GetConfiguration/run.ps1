using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Get Current Script Location
$Location = Get-Location
$AssemblyPath = [System.IO.Path]::Combine($Location.Path,"DLLs","ConfigurationBuilderCore.dll")

# Load the Assembly
Add-Type -LiteralPath $AssemblyPath


# Build the Configuration
$AddedConfiguration = [System.Collections.Generic.List[ConfigurationBuilder.HTMLObject]]::New()
$Path = [System.IO.Path]::Combine($Location.Path, "Configurations")
$Files = Get-ChildItem -LiteralPath $Path -Filter *.ps1

# Counter
$i = 0

# Build the Configuration 
ForEach ($File in $Files) {
    # Dot Source the Items in.
    $Configuration = . $File.FullName
    # Compile
    # The Configuration Builder is a custom Class that converts PowerShell Hashtables
    # in C# Objects, which enables easy seralization/ de-seralization
    $HTMLObject = [ConfigurationBuilder.HTMLObject]::Add($Configuration.RunbookPSObject,
                                                         $Configuration.RestBody, 
                                                         $Configuration.HTMLContent,
                                                         $i++)

    $null = $AddedConfiguration.Add($HTMLObject)
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $AddedConfiguration | ConvertTo-Json -Depth 5
})
