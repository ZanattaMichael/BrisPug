
#Get-LabVirtualNetworkDefinition | Remove-LabVirtualNetworkDefinition
#Get-LabMachineDefinition | Remove-LabMachineDefinition
#Get-Lab | Remove-Lab

# Create Your Lab Enviroment and Give it a Name
# Here I am storing my lab in P:\CatCorp
New-LabDefinition -Name CatCorp -DefaultVirtualizationEngine HyperV -VmPath "P:\CatCorpLab\" -UseStaticMemory

#and the domain definition with the domain admin account
Add-LabDomainDefinition -Name catcorp.com -AdminUser Install -AdminPassword 123Password
# Add the install account
Set-LabInstallationCredential -Username Install -Password 123Password

# Add the Operating System ISO Image
Add-LabIsoImageDefinition -Name Server2016 -Path "$($global:labSources)\ISOs\en_windows_server_version_1903_updated_jan_2020_x64_dvd_8ec19b09.iso"

# Add the HyperV Switch Name. This one is in use by other VM's that I run
Add-LabVirtualNetworkDefinition -Name 'ExternalSwitch'

# Some default Parameters
$PSDefaultParameterValues = @{
    # All VM switches point to my External Switch
    'Add-LabMachineDefinition:Network' = 'ExternalSwitch'
    # 4GB of Ram
    'Add-LabMachineDefinition:Memory' = '4GB'
    # Join the Machine to Catcorp.com
    'Add-LabMachineDefinition:DomainName' = 'catcorp.com'
    # The Operating System. Use: Get-LabAvailableOperatingSystem to get a list of the OS's that are in the $Global:labSources Folder
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Datacenter (Desktop Experience)'
}

# Add my default gateway
$PSDefaultParameterValues.Add('Add-LabMachineDefinition:Gateway', '192.168.0.254')

# Create Domain Controller
#
# Name: Name of the VM
# Roles: You can specify the role of the VM, Use RootDC for a New Domain Controller in a new forest
# Memory: RAM for the VM's
# DomainName: The Domain to Join. The module is smart and will wait for the domain controller to be built, before being the member servers.
# IP: Local IP Address
# DNS: DNS Server
Add-LabMachineDefinition -Name DC1 -Roles RootDC -Memory 4GB -Processors 2 -DomainName catcorp.com -IpAddress 192.168.0.1 -DnsServer1 127.0.0.1

# Create File Server
Add-LabMachineDefinition -Name FS1 -Roles FileServer -Memory 4GB -Processors 2 -DomainName catcorp.com -IpAddress 192.168.0.2 -DnsServer1 192.168.0.1

# Exchange
# Exchange is a custom role.
$role = Get-LabPostInstallationActivity -CustomRole Exchange2016 -Properties @{ OrganizationName = 'CatCorp' }
Add-LabMachineDefinition -Name EXCH1 -Memory 8GB -Processors 2 -DomainName catcorp.com -IpAddress 10.4.200.42 -DnsServer1 192.168.0.3 -PostInstallationActivity $role

# Create Hybrid Runbook Servers Pool
Add-LabMachineDefinition -Name AAHRBW1 -Memory 4GB -Processors 2 -DomainName catcorp.com -IpAddress 10.4.200.44 -DnsServer1 192.168.0.4
Add-LabMachineDefinition -Name AAHRBW2 -Memory 4GB -Processors 2 -DomainName catcorp.com -IpAddress 10.4.200.45 -DnsServer1 192.168.0.5

#Exchange 2016 required at least kb3206632. Hence before installing Exchange 2016, the update is applied
#Alternativly, you can create an updated ISO as described in the introduction script '11 ISO Offline Patching.ps1' or download an updates image that
#has the fix already included.
Install-Lab -NetworkSwitches -BaseImages -VMs -Domains -StartRemainingMachines

Install-LabSoftwarePackage -Path "$labSources\OSUpdates\2016\Exchange2016.msu" -ComputerName EXCH1 -Timeout 60
Install-LabSoftwarePackage -Path "$labSources\OSUpdates\2016\ndp48-x86-x64-allos-enu.exe" -ComputerName EXCH1 -Timeout 60
Install-LabSoftwarePackage -Path "$labSources\OSUpdates\2016\UcmaRuntimeSetup.exe" -ComputerName EXCH1 -Timeout 60

Restart-LabVM -ComputerName EXCH1 -Wait

Install-Lab -PostInstallations

Show-LabDeploymentSummary -Detailed
