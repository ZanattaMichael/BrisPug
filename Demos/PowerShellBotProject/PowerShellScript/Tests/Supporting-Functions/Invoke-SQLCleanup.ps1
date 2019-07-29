

#region Invoke-SQLCleanup
# Function to cleanup all my Tests from SQL.
# Author: Michael Zanatta
#----------------------------------------------------------------------------------------------------
function Invoke-SQLCleanup {
    #------------------------------------------------------------------------------------------------
    #Requires -Modules Az
    
    # Pull the SQL Password
    $SQLPassword = (Get-AzKeyVaultSecret -VaultName BrisPug -Name brispugbotdemo).SecretValue

    # Define the SQL Query
    # TO DO: ISSUE HERE WITH POSSIBILITY OF EXECUTING THE CODE TWICE DUE TO SERVICE RUNNING JOBS ASYNCHRONOUSLY
    $SQLParams = @{
        CommandText = "DELETE FROM [dbo].[remote_code_execution] WHERE ComputerNameTarget = 'PESTERTEST'"
        DatabaseName = "RemoteBotDatabase"
        ServerName = "tcp:brispug.database.windows.net"
        ServerPort = "1433"
        Credential = [pscredential]::New('brispugbotdemo', $SQLPassword)
        Encrypt = $true
    }

    try {
        Invoke-SQLQuery @SQLParams
    } catch {
        # Write a Warning Message
        Write-Warning "Failed to Cleanup Test Entries in Database. This could have a negative impact on further tests. Details below:"
        Write-Warning $_.ErrorDetails.Message
    }
    
}