
#Get-LabVirtualNetworkDefinition | Remove-LabVirtualNetworkDefinition
#Get-LabMachineDefinition | Remove-LabMachineDefinition
#Get-Lab | Remove-Lab

New-LabDefinition -Name CatCorp -DefaultVirtualizationEngine HyperV -VmPath "P:\CatCorpLab\" -UseStaticMemory

#and the domain definition with the domain admin account
Add-LabDomainDefinition -Name catcorp.com -AdminUser Install -AdminPassword 123Password

Add-LabIsoImageDefinition -Name Server2016 -Path "$($global:labSources)\ISOs\en_windows_server_version_1903_updated_jan_2020_x64_dvd_8ec19b09.iso"

Set-LabInstallationCredential -Username Install -Password 123Password

Add-LabVirtualNetworkDefinition -Name 'ExternalSwitch'

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = 'ExternalSwitch'
    'Add-LabMachineDefinition:Memory' = '4GB'
    'Add-LabMachineDefinition:DomainName' = 'catcorp.com'
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Datacenter (Desktop Experience)'
}
$PSDefaultParameterValues.Add('Add-LabMachineDefinition:Gateway', '10.4.200.254')

# Create Domain Controller
Add-LabMachineDefinition -Name DC1 -Roles RootDC -Memory 4GB -Processors 2 -DomainName catcorp.com -IpAddress 10.4.200.50 -DnsServer1 127.0.0.1

# Create File Server
Add-LabMachineDefinition -Name FS1 -Roles FileServer -Memory 4GB -Processors 2 -DomainName catcorp.com -IpAddress 10.4.200.51 -DnsServer1 10.4.200.50

# Exchange
$role = Get-LabPostInstallationActivity -CustomRole Exchange2016 -Properties @{ OrganizationName = 'CatCorp' }
Add-LabMachineDefinition -Name EXCH1 -Memory 8GB -Processors 2 -DomainName catcorp.com -IpAddress 10.4.200.52 -DnsServer1 10.4.200.50 -PostInstallationActivity $role

# Create Hybrid Runbook Servers
Add-LabMachineDefinition -Name AAHRBW1 -Memory 4GB -Processors 2 -DomainName catcorp.com -IpAddress 10.4.200.54 -DnsServer1 10.4.200.50
Add-LabMachineDefinition -Name AAHRBW2 -Memory 4GB -Processors 2 -DomainName catcorp.com -IpAddress 10.4.200.55 -DnsServer1 10.4.200.50

#Exchange 2016 required at least kb3206632. Hence before installing Exchange 2016, the update is applied
#Alternativly, you can create an updated ISO as described in the introduction script '11 ISO Offline Patching.ps1' or download an updates image that
#has the fix already included.
Install-Lab -NetworkSwitches -BaseImages -VMs -Domains -StartRemainingMachines

Install-LabSoftwarePackage -Path "$labSources\OSUpdates\2016\Exchange2016.msu" -ComputerName EXCH1 -Timeout 60
Install-LabSoftwarePackage -Path "$labSources\OSUpdates\2016\ndp48-x86-x64-allos-enu.exe" -ComputerName EXCH1 -Timeout 60
Install-LabSoftwarePackage -Path "$labSources\OSUpdates\2016\UcmaRuntimeSetup.exe" -ComputerName EXCH1 -Timeout 60

Restart-LabVM -ComputerName EXCH1 -Wait

Install-Lab -PostInstallations

Checkpoint-LabVM -ComputerName EXCH1, DC1, AAHRBW1, AAHRBW2, FS1 -SnapshotName PREDemo

Show-LabDeploymentSummary -Detailed
