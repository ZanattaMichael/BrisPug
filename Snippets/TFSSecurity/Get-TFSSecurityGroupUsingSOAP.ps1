<#
$TFSURL = 'http://TFSSERVER:8080/tfs'
$TFSURL = 'http://10.4.200.155:8080/tfs/DefaultCollection'


$localService = New-WebServiceProxy -Uri "http://TFSSERVER:8080/tfs/TeamFoundation/Administration/v3.0/LocationService.asmx" -UseDefaultCredential
$securityService = New-WebServiceProxy -Uri "$TFSURL/TeamFoundation/Administration/v3.0/SecurityService.asmx" -UseDefaultCredential
$IdentityManagmentService = New-WebServiceProxy -Uri "$TFSURL/TeamFoundation/Administration/v3.0/IdentityManagementService.asmx?WSDL" -UseDefaultCredential

# Get the groups:
$IdentityManagmentService.ListApplicationGroups($null,$null,1,$null,$null)
# Create a Group
$groupIdentity = $IdentityManagmentService.CreateApplicationGroup($null,'TEST16','')
$ApplicationGroupIdentity = $IdentityManagmentService.ReadIdentitiesByDescriptor($groupIdentity, 1, $null, 1, $null, $null)
#>

Function Connect-TFSServer {
    param(
        [Parameter(
            Mandatory
        )]
        [String]
        $URL
    )

    #Add-Type -LiteralPath "C:\Users\WebUser1\Desktop\Tools\Microsoft.TeamFoundation.Client.dll"
    #Add-Type -LiteralPath "C:\Users\WebUser1\Desktop\Tools\Microsoft.TeamFoundation.Common.dll"

    $ErrorActionPreference = 'Stop'

    $Global:TFSSOAP = [PSCustomObject]@{
        $localService = New-WebServiceProxy -Uri "$URL/TeamFoundation/Administration/v3.0/LocationService.asmx" -UseDefaultCredential
        $securityService = New-WebServiceProxy -Uri "$URL/TeamFoundation/Administration/v3.0/SecurityService.asmx" -UseDefaultCredential
    }

    Write-Host "Connected." -ForegroundColor Green

}


Function New-TFSSecurityGroup {
    param(
        [Parameter(Mandatory)]
        [String]
        $URL,
        [Parameter(Mandatory)]
        [String]
        $Name,
        [String]
        $Description
    )

    $ErrorActionPreference = 'Stop'

    $params = @{
        URI = "$URL/TeamFoundation/Administration/v3.0/IdentityManagementService.asmx?WSDL"
        UseDefaultCredential = $true
    }

    # Connect to the WDSL
    $IdentityManagmentService = New-WebServiceProxy @params


    # Create the Group
    $groupIdentity = $IdentityManagmentService.CreateApplicationGroup($null,$Name,$Description)
    # Return the Identity
    $IdentityManagmentService.ReadIdentitiesByDescriptor($groupIdentity, 1, $null, 1, $null, $null)

}


Function Get-TFSUser($identity) {

    $IdentityManagmentService.ReadIdentitiesByDescriptor($identity, $null, 1, 1, $null, $null)

}

function Get-TFSSecurityGroup {
    [CmdletBinding(DefaultParameterSetName = 'Identity')]
    param(
        [Parameter(Mandatory,ParameterSetName = 'Identity')]
        [Parameter(Mandatory,ParameterSetName = 'All')]
        [String]
        $URL,

        [Parameter(Mandatory,ParameterSetName = 'All')]
        [Switch]
        $All,

        [Parameter(ParameterSetName = 'All')]
        [ScriptBlock]
        $Filter,

        [Parameter(Mandatory,ParameterSetName = 'Identity')]
        [Object]
        $Identity
    )

    $ErrorActionPreference = 'Stop'

    $params = @{
        URI = "$URL/TeamFoundation/Administration/v3.0/IdentityManagementService.asmx?WSDL"
        UseDefaultCredential = $true
    }

    # Connect to the WDSL
    $IdentityManagmentService = New-WebServiceProxy @params

    if ($PSCmdlet.ParameterSetName -eq 'All') {

        # Enumerate the Users
        $ApplicationGroups = $IdentityManagmentService.ListApplicationGroups($null,$null,1,$null,$null)
        $GroupIdentities = $IdentityManagmentService.ReadIdentities($null, $ApplicationGroups.DisplayName, 2, $null, 1, $null, $null)

        if ($Filter) {
            $GroupIdentities = $GroupIdentities | Where-Object $Filter
        }

    } else {
        $GroupIdentities = $IdentityManagmentService.ReadIdentities($null, $Identity, 2, $null, 1, $null, $null)
    }

    $GroupIdentities | ForEach-Object {           
        $_ | Select-Object *, 
        @{ 
            Name = 'MemberIdentities'
            Exp = {$IdentityManagmentService.ReadIdentitiesByDescriptor($_.Members, $null, 1, 1, $null, $null)}
        },
        @{ 
            Name = 'MemberOfIdentities'
            Exp = {$IdentityManagmentService.ReadIdentitiesByDescriptor($_.MemberOf, $null, 1, 1, $null, $null)}
        }
    }

}

function Update-TFSGroupIdentity {

    param(
        [Parameter(Mandatory)]
        [String]
        $URL,

        [Parameter(Mandatory)]
        [Object]
        $Identity,

        [String]
        $NewName,

        [String]
        $NewDescription

    )

    $ErrorActionPreference = 'Stop'


    $params = @{
        URI = "$URL/TeamFoundation/Administration/v3.0/IdentityManagementService.asmx?WSDL"
        #URI = "$URL/Services/v3.0/IdentityManagementService.asmx?WSDL"
        UseDefaultCredential = $true
    }

    # Connect to the WDSL
    $IdentityManagmentService = New-WebServiceProxy @params

    $GroupIdentity = $IdentityManagmentService.ReadIdentities($null, $Identity, $null, 1, 1, $null, $null)

    if (-not($GroupIdentity)) { Throw 'Cannot find group' }

    if ($NewDescription) {
        $null = $IdentityManagmentService.UpdateApplicationGroup($GroupIdentity.Descriptor, 2, $NewDescription)
    }

    if ($NewName) {
        $null = $IdentityManagmentService.UpdateApplicationGroup($GroupIdentity.Descriptor, 1, $NewName)
        $Identity = $NewName
    }

    Get-TFSSecurityGroup -URL $URL -Identity $Identity

}

function Add-TFSMemberToGroup {

    param(
        [Parameter(Mandatory)]
        [String]
        $URL,

        [Parameter(Mandatory)]
        [Object]
        $Identity,

        [String]
        $Member

    )

    $ErrorActionPreference = 'Stop'


    $params = @{
        URI = "$URL/TeamFoundation/Administration/v3.0/IdentityManagementService.asmx?WSDL"
        #URI = "$URL/Services/v3.0/IdentityManagementService.asmx?WSDL"
        UseDefaultCredential = $true
    }

    # Connect to the WDSL
    $IdentityManagmentService = New-WebServiceProxy @params

    $GroupIdentity = $IdentityManagmentService.ReadIdentities($null, $Identity, $null, 1, 1, $null, $null)
    $MemberPersonIdentity = $IdentityManagmentService.ReadIdentities($null, $Member, $null, 1, 1, $null, $null)

    if (-not($GroupIdentity)) { Throw 'Cannot find group' }

    if ($NewDescription) {
        $null = $IdentityManagmentService.UpdateApplicationGroup($GroupIdentity.Descriptor, 2, $NewDescription)
    }

    if ($NewName) {
        $null = $IdentityManagmentService.UpdateApplicationGroup($GroupIdentity.Descriptor, 1, $NewName)
        $Identity = $NewName
    }

    Get-TFSSecurityGroup -URL $URL -Identity $Identity


}