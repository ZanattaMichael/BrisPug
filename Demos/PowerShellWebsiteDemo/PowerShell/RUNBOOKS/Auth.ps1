Param (
	[parameter(Mandatory=$True,Position=1)]
	[String]
	$UserName,
	[parameter(Mandatory=$True,Position=2)]
	[String]
    $Password,
    [parameter(Mandatory=$True,Position=3)]
	[String]
    $MfaPin
)

$helperPath = $(Get-AutomationVariable -Name 'HelperPath')
$userProfilePath = $(Get-AutomationVariable -Name 'UserProfile')

# Dot Source my Helper in!
Get-ChildItem -LiteralPath $helperPath -File | ForEach-Object {. $_.FullName }

#
# Load User Profile in
#

# Test the Path Make Sure it Exists
if (-not(Test-Path -LiteralPath $userProfilePath -ErrorAction SilentlyContinue)) {
    # Return back to the caller
    return (ConvertTo-Json -InputObject @{ error = "Cannot find the path"})
}

#
# Load the User Profile

try {
    $UserObject = Get-Content -LiteralPath $userProfilePath | ConvertFrom-Json
} catch {
    # Return to the caller
    return (ConvertTo-Json -InputObject @{ error = $_.ErrorMessage })
}

#
# Test the User Objects

if (-not(Test-ObjectProperty -object $UserObject -property username, password, mfasecretkey, cooldata)) {
    # Return to the caller
    return (ConvertTo-Json -InputObject @{ error = "User Validation Failed"})
}

#
# Validate User Credentials

# Validate if the User Exists
if ($UserName -ne $UserObject.username) {
    # Return to the caller
    return (ConvertTo-Json -InputObject @{ error = "Incorrect Username or Password. Please try again."})
}

# Validate MFA
if ((Get-GoogleAuthenticatorPin -Secret $UserObject.mfasecretkey)."PIN Code".Replace(" ","") -ne $MfaPin) {
    return (ConvertTo-Json -InputObject @{ error = "Incorrect MFA. Please try again."})
}

# Validate the Password
if ($UserObject.password -cne $Password) {
    # Return to the caller
    return (ConvertTo-Json -InputObject @{ error = "Incorrect Username or Password. Please try again."})
}

# Since everything else has evualted to be false, this must be true
return (ConvertTo-Json -InputObject @{ success = $UserObject})

