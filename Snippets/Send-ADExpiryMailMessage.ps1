Import-Module ActiveDirectory

# Days before ExpiryTime
$DaysBeforeExpiry = -7
# Months before ExpiryTime
$MonthsToRemind = -2

# Today's Date
$Now = Get-Date -Hour 00 -Minute 00 -Second 00

# Send Email 365
$SendMailMessageParams = @{
    Server = "ServerName"
    # You might need to load credentials. This get's a bit tricky, but you will need to presave the credentials
    # as a secure string on the disk. This when the creds are saved, windows uses the DAPI (Data Protection API)
    # and will encrypt the file with a user certificate, that is ONLY accessiable to that user.
    # So if you use a differen't script, it won't work.
    # I would also encourage you to take a look at Azure Automation, becuase you can shove all your code there.
    # You can execute tasks locally using Hybrid runbook workers and do some other cool things with it.
    # One of the benifits is the ability to save credentials within the cloud.
    #
    # Anyway, let's backup those creds:
    # 1: Open PowerShell as the User Context that you want to run as: (Use RunAs)
    # 2: Start PowerShell
    # 3: Run the following: Get-Credential | Export-CliXML -LiteralPath "CRED FILE PATH"
    # This will prompt for credentials and export the configuration.
    Credential = Import-Clixml -LiteralPath "Path to Creds"
    SmtpServer  = 'smtp.office365.com'
    Port  = '587' # or '25' if not using TLS
    UseSSL= $true ## or not if using non-TLS
    From  = 'sender@yourdomain.com'
    Subject  = "Subject"
    Body  = 'This is a test email using SMTP Client Submission'
    BodyAsHtml = $true # Send the email as a HTML email 
}

# OU Path
$OUDNPath = 'OU=Brisbane,DC=catcorp,DC=com'

# Extract all users. Can take some time.
# We use Select Expressions to format the data to make our lives easier. The key here is to format as day, month and year simplifying times.
$ADUsers = Get-ADUser -Filter * -Properties DisplayName, msDS-UserPasswordExpiryTimeComputed, Mail | 
 Select-Object *, @{Name="PasswordExpiry";Expression={[DateTime]::FromFileTime($_. "msDS-UserPasswordExpiryTimeComputed").ToString("dd-MM-yyyy")}}
# Get all users from a specifc OU
# We use Select Expressions to format the data to make our lives easier. The key here is to format as day, month and year simplifying times.
$ADUsers = Get-ADUser -Filter * -SearchBase $OUDNPath -Properties  DisplayName, msDS-UserPasswordExpiryTimeComputed, Mail | 
 Select-Object *, @{Name="PasswordExpiry";Expression={[DateTime]::FromFileTime($_. "msDS-UserPasswordExpiryTimeComputed").ToString("dd-MM-yyyy")}}
# If you only want to extract enabled users, you can do the following:
$ADUsers = Get-ADUser -Filter {enabled -eq $true} -Properties DisplayName, msDS-UserPasswordExpiryTimeComputed, Mail | 
 Select-Object *, @{Name="PasswordExpiry";Expression={[DateTime]::FromFileTime($_. "msDS-UserPasswordExpiryTimeComputed").ToString("dd-MM-yyyy")}}

#
# Let's filter the data into their respective groups
#

#
# Send Email Notifications of Email Expiries

$ADUsers.Where{
                # Exclude any that are null and exclude any that don't have email addresses.
                # It's best to do it here, since PowerShell will discard
                # the condition at the first $false result. This way we don't have to write
                # overly-complicated logic.
                ($null -ne $_.PasswordExpiry) -and                 
                ($null -ne $_.Mail) -and
                # Cast as a date and perform the comparison.
                ((Get-Date $_.PasswordExpiry).AddDays($DaysBeforeExpiry) -eq $now)                
              } | ForEach-Object {
                    # Set the mailbox recipient.
                    $SendMailMessageParams.To = $_.Mail
                    $SendMailMessageParams.Subject = "Your Password will expire in 7 Days!"
                    # Send the mail message
                    # Time to Splat it in!
                    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7
                    Send-MailMessage @SendMailMessageParams
              }

#
# Send Email Notifications when elapsed months pass

$ADUsers.Where{
                # Exclude any that are null and exclude any that don't have email addresses.
                # It's best to do it here, since PowerShell will discard
                # the condition at the first $false result. This way we don't have to write
                # overly-complicated logic.
                ($null -ne $_.PasswordExpiry) -and 
                ($null -ne $_.Mail) -and
                # Cast as a date and perform the comparison.
                ((Get-Date $_.PasswordExpiry).AddMonths($MonthsToRemind) -eq $now)                
              } | ForEach-Object {
                    # Set the mailbox recipient.
                    $SendMailMessageParams.To = $_.Mail
                    $SendMailMessageParams.Subject = "Please consider changing your password!"
                    # Send the mail message
                    # Time to Splat it in!
                    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7
                    Send-MailMessage @SendMailMessageParams
              }
