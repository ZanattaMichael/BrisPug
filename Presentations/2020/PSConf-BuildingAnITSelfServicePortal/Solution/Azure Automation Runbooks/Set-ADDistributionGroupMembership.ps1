
#region Get-ADMembers
Function Get-ADMembers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Group
    )

    begin {
        # Create a new local set of members
        $Members = [System.Collections.Generic.List[Microsoft.ActiveDirectory.Management.ADObject]]::New()
    }

    process {
        # Get the AD Object
        $ADObject = Get-ADObject $Group.DistinguishedName -Properties UserPrincipalName

        switch ($ADObject.ObjectClass) {
            "user" { $Members.Add($ADObject) }
            "group" { $ADObject | Get-ADMembers | ForEach-Object { $Members.Add($_) } }
            default { Write-Error "Unexpected Value"; continue; }
        }
    }
    end {
        Write-Output $Members | Select-Object -Unique
    }
}
#endregion Get-ADMembers

#
# Connect to Exchange:

$SessionOpt = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://EXCH1/powershell/ -SessionOption $SessionOpt

Import-PSSession $Session -AllowClobber

#
# Grab all the Distro Groups

$ADDistroGroups = Get-ADGroup -Filter {SamAccountName -like "*DistributionGroup" -and GroupCategory -eq "Distribution"} -Properties *

ForEach ($ADDistroGroup in $ADDistroGroups) {

    # Fetch the Owner
    try {
        $OwnerGroup = Get-ADGroupMembers -Identity $ADDistroGroup.Description
    } catch {
        Write-Error $_
        continue;
    }

    $params = @{
        Identity = $ADDistroGroup.Email
        ManagedBy = ($OwnerGroup | Get-ADMembers).UserPrincipalName
    }

    # Update the Group
    Set-DistributionGroup @params

}

# Remove our Session
Remove-PSSession $Session