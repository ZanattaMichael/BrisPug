$TFSURL = 'http://TFSSERVER:8080/tfs'

$localService = New-WebServiceProxy -Uri "$TFSURL/TeamFoundation/Administration/v3.0/LocationService.asmx" -UseDefaultCredential
$securityService = New-WebServiceProxy -Uri "$TFSURL/TeamFoundation/Administration/v3.0/SecurityService.asmx" -UseDefaultCredential
$IdentityManagmentService = New-WebServiceProxy -Uri "$TFSURL/TeamFoundation/Administration/v3.0/IdentityManagementService.asmx" -UseDefaultCredential

# Get the groups:
$IdentityManagmentService.ListApplicationGroups($null,$null,1,$null,$null)