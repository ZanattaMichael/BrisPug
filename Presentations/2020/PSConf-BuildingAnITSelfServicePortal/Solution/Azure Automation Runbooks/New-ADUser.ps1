[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]
    $firstname,
    [Parameter(Mandatory)]
    [String]
    $lastname,
    [Parameter(Mandatory)]
    [String]
    $RoleGroup
)

#
# Set Error Action to Stop
$ErrorActionPreference = "Stop"

#
# Connect to Exchange:
$SessionParams = @{
    ConfigurationName = 'Microsoft.Exchange'
    ConnectionUri = 'http://EXCH1/PowerShell/'
    Authentication = 'Kerberos'
    SessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
}

$Session = New-PSSession @SessionParams
$null = Import-PSSession $Session -DisableNameChecking -AllowClobber

#
# Create our Active Directory User

$params = @{
    Path = "OU=Users,OU=Brisbane,DC=catcorp,DC=com"
    DisplayName = "{0} {1}" -f $FirstName, $LastName
    Name = "{0} {1}" -f $FirstName, $LastName
    GivenName = $FirstName
    Surname = $LastName
    SamAccountName = "{0}.{1}" -f $FirstName, $LastName
    UserPrincipalName = "{0}.{1}@catcorp.com" -f $FirstName, $LastName
    EmailAddress = "{0}.{1}@catcorp.com" -f $FirstName, $LastName
}

#
# Go Ahead and Create the Account Name
New-ADUser @params

#
# Add the User to the Role Group

Add-ADGroupMember -Identity $RoleGroup -Members $params.SamAccountName

#
# Enable the User's Mailbox
$Mailbox = Enable-Mailbox -Identity $params.UserPrincipalName

#
# Remove the Exchange Session
Get-PSSession | Remove-PSSession