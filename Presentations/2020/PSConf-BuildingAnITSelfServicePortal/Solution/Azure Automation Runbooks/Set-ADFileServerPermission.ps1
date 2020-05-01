[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]
    $ADFileAccessGroupName,
    [Parameter(Mandatory)]
    [String]
    $ADRoleGroupName
)

#
# AD Role Group
$ADRoleGroup = Get-ADGroup $ADRoleGroupName

#
# Add that user to the respective role group
Add-ADGroupMember -Identity $ADFileAccessGroupName -Member $ADRoleGroup.UserPrincipalName

