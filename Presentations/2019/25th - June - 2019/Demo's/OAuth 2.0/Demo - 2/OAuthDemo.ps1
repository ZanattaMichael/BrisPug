
# System Defined. NET TLS SSL Settings
# Set the TLS Security Setting

# Combine the set and existing protocols
$security_protocols = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::SystemDefault
# Check for TLS 1.1 and Add
if ([Net.SecurityProtocolType].GetMember("Tls11").Count -gt 0) {
    $security_protocols = $security_protocols -bor [Net.SecurityProtocolType]::Tls11
}
# Check for TLS 1.2 and Add
if ([Net.SecurityProtocolType].GetMember("Tls12").Count -gt 0) {
    $security_protocols = $security_protocols -bor [Net.SecurityProtocolType]::Tls12
}
# Set the Updated Protocols
[Net.ServicePointManager]::SecurityProtocol = $security_protocols

#
# Cd to the Script Repo

$ScriptPath = "D:\Temp\OAuth 2.0\Demo - 2\Classes"

# Load the Classes in

# Load the Internet Explorer Assemblies In
$null = [reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
. (Join-Path -Path $ScriptPath -ChildPath "\InternetExplorerForm.ps1")

# Load the URI Builder Class in
. (Join-Path -Path $ScriptPath -ChildPath "\URIBuilder.ps1")

# Load the OAuthAuthentication Class in
. (Join-Path -Path $ScriptPath -ChildPath "\OAuthAuthentication.ps1")

# Load the Test-Object Property Method in
. (Join-Path -Path $ScriptPath -ChildPath "\Test-ObjectProperty.ps1")

#
# Attempt to Create an OAuth Object

# Arguments for Object
$ClientId = ""
$ClientSecret = ""
$CallbackURL = "https://127.0.0.1"
$ClientScope = "user"

# Let's create an Object to Authenticate and Store the Token information
$OAuthObject = [OAuthAuthentication]::new($ClientId, $ClientSecret, $CallbackURL, $ClientScope)

# Let's do a test to see if our token was successfull
Invoke-RestMethod -Uri "https://api.github.com/user" -Headers @{"Authorization" = ("token {0}" -f $OAuthObject.client_access_token)} -Method Get -ContentType "application/json"