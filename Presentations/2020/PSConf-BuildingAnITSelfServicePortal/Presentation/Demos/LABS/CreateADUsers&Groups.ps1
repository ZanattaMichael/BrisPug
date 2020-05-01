New-ADOrganizationalUnit -Name "Brisbane" -Path "DC=CATCORP,DC=COM"
New-ADOrganizationalUnit -Name "ServiceAccounts" -Path "OU=Brisbane,DC=CATCORP,DC=COM"
New-ADOrganizationalUnit -Name "Groups" -Path "OU=Brisbane,DC=CATCORP,DC=COM"
New-ADOrganizationalUnit -Name "Users" -Path "OU=Brisbane,DC=CATCORP,DC=COM"
New-ADOrganizationalUnit -Name "Distribution Groups" -Path "OU=Brisbane,DC=CATCORP,DC=COM"

#
# Create 300 Random User Accounts

0 .. 300 | ForEach-Object {

    $userDetails = Invoke-RestMethod -Uri https://randomuser.me/api/?nat=gb

    $params = @{
        Name = "{0}.{1}" -f $userDetails.Results.Name.first, $userDetails.Results.Name.last
        Path = "OU=Users,OU=Brisbane,DC=CATCORP,DC=COM"
        OtherAttributes = @{
            Mail = "{0}.{1}@catcorp.com" -f $userDetails.Results.Name.first, $userDetails.Results.Name.last
        }
        Enabled = $true
        City = "Brisbane"
        Company = "Catcorp"
        Surname = $userDetails.Results.Name.last
        GivenName = $userDetails.Results.Name.first
        HomePhone  = $userDetails.Results.phone
        MobilePhone = $userDetails.Results.cell
        DisplayName = "{0}.{1}@catcorp.com" -f $userDetails.Results.Name.first, $userDetails.Results.Name.last
        AccountPassword = "123Password" | ConvertTo-SecureString -AsPlainText -Force
        SamAccountName = "{0}.{1}" -f $userDetails.Results.Name.first, $userDetails.Results.Name.last
        UserPrincipalName = "{0}.{1}@catcorp.com" -f $userDetails.Results.Name.first, $userDetails.Results.Name.last
    }

    New-ADUser @params

}


#
# Create Some AD Groups
#

$Users = Get-ADUser -SearchBase "OU=Users,OU=Brisbane,DC=CATCORP,DC=COM" -Filter *

# Departments
$Deparments = @('Finance Users', 'IT Users', 'Human Resource', 'Other Users', 'Executive', 'Marketing', 'Admin')

# Other Random Groups
$RandomGroups = @('Project 2019', '2020 Software Updates', 'BYOB Version 1', 'Accounts Payable', 'Invoices', 'Software', 'Projects', 'Payslips')

$Deparments | ForEach-Object {

    $params = @{
        DisplayName = $_
        Name = $_
        SamAccountName = $_
        Path = "OU=Groups,OU=Brisbane,DC=CATCORP,DC=COM"
        GroupScope = "DomainLocal"
    }

    New-ADGroup @params

}

$RandomGroups | ForEach-Object {

    $params = @{
        DisplayName = $_
        Name = $_
        SamAccountName = $_
        Path = "OU=Groups,OU=Brisbane,DC=CATCORP,DC=COM"
        GroupScope = "DomainLocal"
    }

    New-ADGroup @params

}

#
# Randomly Add AD Users
#

$Users | ForEach-Object {
    Get-ADGroup $(Get-Random $RandomGroups) | Add-ADGroupMember -Members $_.SamAccountName
    Get-ADGroup $(Get-Random $Deparments) | Add-ADGroupMember -Members $_.SamAccountName
}


#
# Mail Enable the User Accounts
#

Get-AdUser -Filter * -SearchBase "OU=BRISBANE,DC=CATCORP,DC=COM" | ForEach-Object { Enable-Mailbox -Identity $_.SamAccountName }