[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]
    $UserName,
    [Parameter(Mandatory)]
    [String]
    $ADRoleGroup
)

#
# AD User
try {
    $ADUser = Get-ADUser -Filter {(samaccountname -eq $UserName) -or (userprincipalname -eq $UserName)}
} Catch {
    Write-Error $_
    Throw $_
}

#
# Add the User to the Role Group
try {
    Add-ADGroupMember -Identity $ADRoleGroup -Members $ADUser.DistinguishedName
} catch {
    Write-Error $_
    Throw $_
}


