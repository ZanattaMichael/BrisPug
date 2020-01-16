#
# We need to get the Computer Name
$ComputerName = Read-Host "Please enter your Computer Name"
#
# Let's Create a New Directory
New-Item -Path E:\ -Name $ComputerName -ItemType Directory
#
# Create a New Virtual Machine
New-VM -Name $ComputerName -Path ("E:\$ComputerName") -SwitchName External -BootDevice VHD
