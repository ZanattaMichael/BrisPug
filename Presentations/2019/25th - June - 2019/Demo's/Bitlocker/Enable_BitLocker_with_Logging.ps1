<#
    .SYNOPSIS
    Encrypts OS drive with bitlocker, adds a recovery password and backs up to Azure AD 

    THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
    RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

    .DESCRIPTION
    Script Features
    * Encrypts OS Drive with specified encryption method
    * If drive is already encrypted but not with specified encryption method, drive will be decrypted and re-ecrypted with correct encryption method
    * Checks for TPM Protector and adds if not present
    * Checks for Recovery Password Protector and adds if not present
    * Backs up Recovery Password to Azure AD
    * Logs written to Event Viewer 'Application' log under source 'Intune Bitlocker Encryption Script' 

    .NOTES
    Complete rewrite of MS Technet script
    Thanks to Rob Hawkins for the Keyprotector detection logic
    Author: Alex Laurie alex.laurie@insynctechnology.com.au

    Version: 4.05
    Added checks for remaining protectors on decrypt and encrypt to prevent duplicates.

    .INPUTS
    Designed to be run from Intune as Administrator. 
    Update parameters to change default encryption method XtsAes256

    .EXAMPLE
    .\Enable_BitLocker_with_Logging.v4.05.ps1

#>

#Requires -Version 4.0
#-- Requires -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]
#Requires -Modules TrustedPlatformModule, BitLocker
#-- Requires -ShellId <ShellId>
#Requires -RunAsAdministrator


#====================================================================================================
#                                             Parameters
#====================================================================================================
#region Parameters

[cmdletbinding()]
param(
  [ValidateNotNullOrEmpty()]
  [string]
  $OSDrive = $env:SystemDrive,

  [parameter()]
  [string]
  [ValidateSet('XtsAes256', 'XtsAes128', 'Aes256', 'Aes128')]
  $encryption_strength = 'XtsAes128'
)

#endregion Parameters

#====================================================================================================
#                                           Initialize
#====================================================================================================
#region  Initialize

# Provision new source for Event log
New-EventLog -LogName Application -Source 'Intune Bitlocker Encryption Script' -ErrorAction SilentlyContinue

#endregion  Initialize

#====================================================================================================
#                                             Functions
#====================================================================================================
#region Functions

function Write-EventLogEntry 
{
  param (
    [parameter(Mandatory,HelpMessage = 'Add help message for user', Position = 0)]
    [String]
    $Message,
    [parameter(Position = 1)]
    [string]
    [ValidateSet('Information', 'Error')]
    $type = 'Information'
  )

  # Specify Parameters
  $log_params = @{
    Logname   = 'Application'
    Source    = 'Intune Bitlocker Encryption Script'
    Entrytype = $type
    EventID   = $(
      if ($type -eq 'Information') 
      {
        Write-Output -InputObject 500 
      }
      else 
      {
        Write-Output -InputObject 501 
      }
    )
    Message   = $Message
  }
  Write-EventLog @log_params
}


function Get-TPMStatus 
{
  # Returns true/false if TPM is ready
  $tpm = Get-Tpm
  if ($tpm.TpmReady -and $tpm.TpmPresent -eq $true) 
  {
    return $true
  }
  else 
  {
    return $false
  }
}

function Test-RecoveryPasswordProtector() 
{
  $AllProtectors = (Get-BitLockerVolume -MountPoint $OSDrive).KeyProtector
  $RecoveryProtector = ($AllProtectors | Where-Object {
      $_.KeyProtectorType -eq 'RecoveryPassword' 
  })
  if (($RecoveryProtector).KeyProtectorType -eq 'RecoveryPassword') 
  {
    Write-EventLogEntry -Message 'Recovery password protector detected'
    return $true
  }
  else 
  {
    Write-EventLogEntry -Message 'Recovery password protector not detected'
    return $false
  }
}

function Test-TpmProtector() 
{
  $AllProtectors = (Get-BitLockerVolume -MountPoint $OSDrive).KeyProtector
  $RecoveryProtector = ($AllProtectors | Where-Object {
      $_.KeyProtectorType -eq 'Tpm' 
  })
  if (($RecoveryProtector).KeyProtectorType -eq 'Tpm') 
  {
    Write-EventLogEntry -Message 'TPM protector detected'
    return $true
  }
  else 
  {
    Write-EventLogEntry -Message 'TPM protector not detected'
    return $false
  }
}

function Set-RecoveryPasswordProtector() 
{
  try 
  {
    Add-BitLockerKeyProtector -MountPoint $OSDrive -RecoveryPasswordProtector 
    Write-EventLogEntry -Message ('Added recovery password protector to bitlocker enabled drive {0}' -f $OSDrive)
  }
  catch 
  {
    throw Write-EventLogEntry -Message 'Error adding recovery password protector to bitlocker enabled drive' -type error
  }
}

function Set-TpmProtector() 
{
  try 
  {
    Add-BitLockerKeyProtector -MountPoint $OSDrive -TpmProtector
    Write-EventLogEntry -Message ('Added TPM protector to bitlocker enabled drive {0}' -f $OSDrive)
  }
  catch 
  {
    throw Write-EventLogEntry -Message 'Error adding TPM protector to bitlocker enabled drive' -type error
  }
}


function Backup-RecoveryPasswordProtector() 
{
  $AllProtectors = (Get-BitLockerVolume -MountPoint $OSDrive).KeyProtector
  $RecoveryProtector = ($AllProtectors | Where-Object {
      $_.KeyProtectorType -eq 'RecoveryPassword' 
  })

  try 
  {
    BackupToAAD-BitLockerKeyProtector -MountPoint $OSDrive -KeyProtectorId $RecoveryProtector.KeyProtectorID
    Write-EventLogEntry -Message 'BitLocker recovery password has been successfully backup up to Azure AD'
  }
  catch 
  {
    throw Write-EventLogEntry -Message 'Error backing up recovery password to Azure AD.' -type error
  }
}

function Invoke-Encryption() 
{
  # Test that TPM is present and ready
  try 
  {
    Write-EventLogEntry -Message 'Checking TPM Status before attempting encryption'
    if (Get-TPMStatus -eq $true) 
    {
      Write-EventLogEntry -Message 'TPM Present and Ready. Beginning encryption process'
    }
  }
  catch 
  {
    throw Write-EventLogEntry -Message 'Issue with TPM. Exiting script' -type error
  }

  # Encrypting OS drive
  try 
  {
    Write-EventLogEntry -Message ('Enabling bitlocker with Recovery Password protector and method {0}' -f $encryption_strength)
    Enable-BitLocker -MountPoint $OSDrive -SkipHardwareTest -UsedSpaceOnly -EncryptionMethod $encryption_strength -RecoveryPasswordProtector
    Write-EventLogEntry -Message ('Bitlocker enabled on {0} with {1} encryption method' -f $OSDrive, $encryption_strength)
  }
  catch 
  {
    throw Write-EventLogEntry -Message ('Error enabling bitlocker on {0}. Exiting script' -f $OSDrive)
  }
}

function Invoke-UnEncryption() 
{
  # Call disable-bitlocker command, reboot after unencryption?
  try 
  {
    Write-EventLogEntry -Message ('Unencrypting bitlocker enabled drive {0}' -f $OSDrive)
    Disable-BitLocker -MountPoint $OSDrive
  }
  catch 
  {
    throw Write-EventLogEntry -Message ('Issue unencrypting bitlocker enabled drive {0}' -f $OSDrive)
  }
}

function Remove-RecoveryPasswordProtectors() 
{
  # Remove all recovery password protectors
  try 
  {
    $RecoveryPasswordProtectors = (Get-BitLockerVolume -MountPoint $env:SystemDrive).KeyProtector | Where-Object {
      $_.KeyProtectorType -contains 'RecoveryPassword' 
    }
    foreach ($PasswordProtector in $RecoveryPasswordProtectors) 
    {
      Remove-BitLockerKeyProtector -MountPoint $OSDrive -KeyProtectorId $($PasswordProtector).KeyProtectorID
      Write-EventLogEntry -Message ('Removed recovery password protector with ID: {0}.KeyProtectorID' -f ($PasswordProtector))
    }
  }
  catch 
  {
    Write-EventLogEntry -Message 'Error removing recovery password protector' -type Error
  }
}

function Remove-TPMProtector() 
{
  # Remove TPM password protector
  try 
  {
    $TPMProtector = (Get-BitLockerVolume -MountPoint $env:SystemDrive).KeyProtector | Where-Object {
      $_.KeyProtectorType -contains 'Tpm' 
    }
    Remove-BitLockerKeyProtector -MountPoint $OSDrive -KeyProtectorId $($TPMProtector).KeyProtectorID
    Write-EventLogEntry -Message ('Removed TPM Protector with ID: {0}.KeyProtectorID' -f ($TPMProtector))
  }
  catch 
  {
    Write-EventLogEntry -Message 'Error removing recovery password protector' -type Error
  }
}


#endregion Functions




#====================================================================================================
#                                             Main-Code
#====================================================================================================
#region MainCode

# Start
Write-EventLogEntry -Message 'Running bitlocker intune encryption script'

# Check if OS drive is ecrpyted with parameter $encryption_strength
if ((Get-BitLockerVolume -MountPoint $OSDrive).VolumeStatus -eq 'FullyEncrypted' -and (Get-BitLockerVolume -MountPoint $OSDrive).EncryptionMethod -eq $encryption_strength) 
{
  Write-EventLogEntry -Message ('BitLocker is already enabled on {0} and the encryption method is correct' -f $OSDrive)
}

# Drive is encrypted but does not meet set encryption method
elseif ((Get-BitLockerVolume -MountPoint $OSDrive).VolumeStatus -eq 'FullyEncrypted' -and (Get-BitLockerVolume -MountPoint $OSDrive).EncryptionMethod -ne $encryption_strength) 
{
  Write-EventLogEntry -Message ('Bitlocker is enabled on {0} but the encryption method does not meet set requirements' -f $OSDrive)
  try 
  {
    # Decrypt OS drive
    Invoke-UnEncryption
        
    # Wait for decryption to finish 
    Do 
    {
      Start-Sleep -Seconds 30
    }
    until ((Get-BitLockerVolume).VolumeStatus -eq 'FullyDecrypted')
    Write-EventLogEntry -Message ('{0} has been fully decrypted' -f $OSDrive)

    # Check for and remove any remaining recovery password protectors
    if (Test-RecoveryPasswordProtector) 
    {
      try 
      {
        Write-EventLogEntry -Message 'Recovery password protector found post decryption. Removing to prevent duplicate entries'
        Remove-RecoveryPasswordProtectors
      }
      catch 
      {
        throw $_
      }
    }

    # Check for and remaining TPM protector
    if (Test-TpmProtector) 
    {
      try 
      {
        Write-EventLogEntry -Message 'TPM protector found post decryption. Removing to prevent encryption issues'
        Remove-TPMProtector
      }
      catch 
      {
        throw $_
      }
    }

    # Trigger encryption with specified encryption method 
    Invoke-Encryption
    Start-Sleep -Seconds 5
  }
  catch 
  {
    throw Write-EventLogEntry -Message ('Failed on encrypting {0} after decryption' -f $OSDrive) -type error
  }
}

# Drive is not FullyDecrypted
elseif ((Get-BitLockerVolume).VolumeStatus -eq 'FullyDecrypted') 
{
  Write-EventLogEntry -Message ('BitLocker is not enabled on {0}' -f $OSDrive)
  try 
  {
    # Check for and remove any remaining recovery password protectors
    if (Test-RecoveryPasswordProtector) 
    {
      try 
      {
        Write-EventLogEntry -Message 'Recovery password protector found pre encryption. Removing to prevent duplicate entries'
        Remove-RecoveryPasswordProtectors
      }
      catch 
      {
        throw $_
      }
    }

    # Check for and remaining TPM protector
    if (Test-TpmProtector) 
    {
      try 
      {
        Write-EventLogEntry -Message 'TPM protector found pre encryption. Removing to prevent encryption issues'
        Remove-TPMProtector
      }
      catch 
      {
        throw $_
      }
    }

    # Encrypt OS Drive with parameter $encryption_strength
    Invoke-Encryption
  }
  catch 
  {
    throw Write-EventLogEntry -Message ('Error thrown encrypting {0}' -f $OSDrive)
  }
}

# Test for Recovery Password Protector. If not found, add Recovery Password Protector
if (-not(Test-RecoveryPasswordProtector)) 
{
  try 
  {
    Set-RecoveryPasswordProtector
  }
  catch 
  {
    throw $_
  }
}

# Test for TPM Protector. If not found, add TPM Protector
if (-not(Test-TpmProtector)) 
{
  try 
  {
    Set-TpmProtector
  }
  catch 
  {
    throw $_
  }
  Write-EventLogEntry -Message 'TPM and Recovery Password protectors are present'
}

# Finally backup the Recovery Password to Azure AD
try 
{
  Backup-RecoveryPasswordProtector
}
catch 
{
  throw $_
}

Write-EventLogEntry -Message 'Script complete'

#endregion MainCode