<#

CONVERT THIS SCRIPT INTO A BASIC FUNCTION

Develop an Script to:
1. Connect to Google.com
2. Enumerate all the links
3. Browse to the links
4. Store and output all enumerated links

$Url = "https://www.google.com"

# Create a Variable Called Request
$Request = Invoke-WebRequest -Uri $Url
# We need to append the Url to the Relitive Paths, ignoring absolute paths
$EnumeratedLinks = $Request.Links.Href | ForEach-Object {
    # Test for Relitive Path    
    if (($_ -notlike "http://*") -and ($_ -notlike "https://*")) {
        # Append the Url to the Relitive Path
        Write-Output ("{0}{1}" -f $Url, $_)
    } else {
        Write-Output $_
    }
}

# Now it's time to iterate through each of the Links and Call the Respective Url
$ChildUrls = $EnumeratedLinks | ForEach-Object { 
    (Invoke-WebRequest -Uri $_).Links.Href
}

# Combine the Links
$CombinedLinks = @()
$CombinedLinks += $EnumeratedLinks
$CombinedLinks += $ChildUrls

# We now need to create absolute Url paths
$CombinedLinks = $CombinedLinks | ForEach-Object {
    
    # Test for Relitive Path
    $CustomObject = [PSCustomObject]@{
        OriginalUrl = $Url
        EnumeratedUrl = $_
    }
    # If it is a relitive path, append the original Url to it.
    if (($_ -notlike "http://*") -and ($_ -notlike "https://*")) {
        # Update the Property with the Url
        $CustomObject.EnumeratedUrl = "{0}{1}" -f $Url, $_
    }

    # Return to the Pipeline
    Write-Output $CustomObject

}

# Return the Combined Links to the Caller
Write-Output $CombinedLinks

#>


Function Format-AbsoluteUrl {
    Param(
        $Url,
        $ParentUrl
    )

    # Test for Relitive Path    
    if (($Url -notlike "http://*") -and ($Url -notlike "https://*")) {
        # Append the Url to the Relitive Path
        Write-Output ("{0}{1}" -f $ParentUrl, $_)
    } else {
        Write-Output $_
    }

}

Function Get-UrlLinks {
    Param(
        $Url
    )
    
    # Create a Variable Called Request
    $Request = Invoke-WebRequest -Uri $Url
    # We need to append the Url to the Relitive Paths, ignoring absolute paths
    $EnumeratedLinks = $Request.Links.Href | ForEach-Object { Format-AbsoluteUrl -Url $_ -ParentUrl $Url }
    
    # Now it's time to iterate through each of the Links and Call the Respective Url
    $ChildUrls = $EnumeratedLinks | ForEach-Object { 
        (Invoke-WebRequest -Uri $_).Links.Href
    }
    
    # Combine the Links
    $CombinedLinks = @()
    $CombinedLinks += $EnumeratedLinks
    $CombinedLinks += $ChildUrls
    
    # We now need to create absolute Url paths
    $CombinedLinks = $CombinedLinks | ForEach-Object {
        
        # Test for Relitive Path
        $CustomObject = [PSCustomObject]@{
            OriginalUrl = $Url
            EnumeratedUrl = Format-AbsoluteUrl -Url $_ -ParentUrl $Url
        }
    
        # Return to the Pipeline
        Write-Output $CustomObject
    
    }
    
    # Return the Combined Links to the Caller
    Write-Output $CombinedLinks   

}

Get-UrlLinks -Url "https://yahoo.com.au"
