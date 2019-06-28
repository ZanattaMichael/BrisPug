using namespace System.Net

param($Request, $TriggerMetadata)
# Input bindings are passed in via param block.

<#
1: Query Server for requested jobs
    Requires:   ComputerName

2: Get the job
    Perform SQLQuery

3: Validate Job
    Check there are:  Multiple Inputs
    Check for:  Null or Empty Inputs -> Error

    $TableResponse = Invoke-SQL

    # Known Good Input
    $GoodInput = @{ 
        jobs = $TableResponse.Where{$_.inputclixml -ne [String]::Empty()}
    } | ConvertTo-Json

    # Invalidate the Bad Input
    $TableResponse.Where{$_.inputclixml -eq [String]::Empty()} | ForEach-Object {

        # SQL Parameters
        $SQLParams = @{
            CommandText = "UPDATE remote_code_execution SET Status = 'error' WHERE GUID = '{0}'";" -f $_.GUID
            DatabaseName = "RemoteBotDatabase"
            ServerName = "tcp:brispug.database.windows.net"
            ServerPort = "1433"
            Credential = [pscredential]::New('brispugbotdemo', $SQLPassword)
            Encrypt = $true
        }
    
        # Write the back response back to SQL
        Try {
            Invoke-SQL @SQLParams
        } Catch {
            # Write Non-Terminating Error
            Write-Error $_.ErrorMessage                       
        }
        
    }


    # Validate the Scripts
    ForEach ($row in $TableResponse.Rows) {

        # Test for Null or Empty Inputs

        if ([String]::IsNullOrEmpty($row.inputclixml)) {
            # ERROR HERE
        }


    }

4: Send the Job back

    @{
        job = @{
            GUID = GUID OF JOB
            CLIXML = 
        }
    }

    Send the job on to be executed.
#>
#===================================================================================
#                                        Functions
#===================================================================================


#region Invoke-SQLQuery
#----------------------------------------------------------------------------------------------------
function Invoke-SQLQuery() {

    <#
    .SYNOPSIS
    Invoke's a SQL Query against a SQL Server.
    
    .DESCRIPTION
    Invoke's a SQL Query against a SQL Server. 
    All errors are treated as terminating errors and are passed back to the caller.
    
    .NOTES
    AUTHOR  : Michael Zanatta
    CREATED : 15/01/2018
    VERSION : 
              1.1 - Updates:
                        Added Support for Microsoft Azure Functions
                        Michael Zanatta - 24/05/2019
              1.0 - Initial Release
    .INPUTS
    This scripts accepts the SQL Query in the Pipeline.
    
    .OUTPUTS
    (If -InvokeRead is specified.) Will return a collection of results from the query. 
    
    .EXAMPLE
     "SELECT * FROM TABLE" | Invoke-SQL -ServerName "MSSQL01" -Database "master" -InvokeRead
     Simple SELECT statement
    
    .EXAMPLE
     "INSERT INTO $($DatabaseTableName)_$($tableType) (FileHash, Path) VALUES ('$($fileHash)', '$($filePath)')" | Invoke-SQL -ServerName "MSSQL01" -Database "testDB"
     Simple INSERT INTO statement.
    
    .EXAMPLE
     "SELECT local.id, local.PATH as localPath, local.FILEHASH as LocalFileHash, s3.PATH as s3Path, s3.FILEHASH as s3FileHash FROM $($DatabaseTableName)_LOCAL local INNER JOIN $($DatabaseTableName)_S3 s3 ON local.id = s3.relatedid AND local.PATH = '$filePath'" | Invoke-SQL -ServerName "MSSQL01" -Database "testDB" -InvokeRead
     More Complex INNER JOIN statement.
    
     ----------------------------------------------------------------------------------------------------
    #>
    [Parameter(ParameterSetName='WindowsLogin')]
    Param (
        [parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName='WindowsLogin')]
        [parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName='ManualLogin')]
        [parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName='ManualLoginEncrypt')]
        [ValidateNotNullOrEmpty()]
        [String]$commandText,

        [parameter(Mandatory, Position = 1, ParameterSetName='WindowsLogin')]
        [parameter(Mandatory, Position = 1, ParameterSetName='ManualLogin')]
        [parameter(Mandatory, Position = 1, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Mandatory, Position = 1, ParameterSetName='ManualLoginEncrypt')]
        [ValidateNotNullOrEmpty()]
        [String]$ServerName,

        [parameter(Position = 2, ParameterSetName='WindowsLogin')]
        [parameter(Position = 2, ParameterSetName='ManualLogin')]
        [parameter(Position = 2, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Position = 2, ParameterSetName='ManualLoginEncrypt')]
        [ValidateNotNullOrEmpty()]
        [String]$ServerPort,

        [parameter(Position = 3, ParameterSetName='WindowsLogin')]
        [parameter(Position = 3, ParameterSetName='ManualLogin')]
        [parameter(Position = 3, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Position = 3, ParameterSetName='ManualLoginEncrypt')]
        [ValidateNotNullOrEmpty()]
        [String]$InstanceName,      

        [parameter(Mandatory, Position = 4, ParameterSetName='WindowsLogin')]
        [parameter(Mandatory, Position = 4, ParameterSetName='ManualLogin')]
        [parameter(Mandatory, Position = 4, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Mandatory, Position = 4, ParameterSetName='ManualLoginEncrypt')]
        [ValidateNotNullOrEmpty()]
        [String]$DatabaseName,

        [parameter(Mandatory, Position = 5, ParameterSetName='WindowsLogin')]
        [parameter(Mandatory, Position = 5, ParameterSetName='WindowsLoginEncrypt')]
        [ValidateNotNullOrEmpty()]
        [Switch]$IntergratedSecurity,

        [parameter(Mandatory, Position = 5, ParameterSetName='ManualLogin')]
        [parameter(Mandatory, Position = 5, ParameterSetName='ManualLoginEncrypt')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,
                
        # Needs to be paramset
        [parameter(Position = 6, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Position = 6, ParameterSetName='ManualLoginEncrypt')]
        [Switch]$Encrypt,

        [parameter(Position = 7, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Position = 7, ParameterSetName='ManualLoginEncrypt')]
        [Switch]$TrustServerCertificate,

        [parameter(Position = 6, ParameterSetName='WindowsLogin')]
        [parameter(Position = 6, ParameterSetName='ManualLogin')]
        [parameter(Position = 8, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Position = 8, ParameterSetName='ManualLoginEncrypt')]
        [Switch]$MultipleActiveResultSets,               

        [parameter(Position = 6, ParameterSetName='WindowsLogin')]
        [parameter(Position = 6, ParameterSetName='ManualLogin')]
        [parameter(Position = 8, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Position = 8, ParameterSetName='ManualLoginEncrypt')]
        [Switch]$PersistSecurityInfo,     

        [parameter(Position = 8, ParameterSetName='WindowsLogin')]
        [parameter(Position = 8, ParameterSetName='ManualLogin')]
        [parameter(Position = 10, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Position = 10, ParameterSetName='ManualLoginEncrypt')] 
        [ValidateNotNullOrEmpty()]       
        [int]$ConnectionTimeout = 30,
        
        [parameter(Position = 9, ParameterSetName='WindowsLogin')]
        [parameter(Position = 9, ParameterSetName='ManualLogin')]
        [parameter(Position = 11, ParameterSetName='WindowsLoginEncrypt')]
        [parameter(Position = 11, ParameterSetName='ManualLoginEncrypt')]  
        [Switch]$InvokeRead

    )


    # Get the Parameter Set Name
    $PSName = $PsCmdlet.ParameterSetName

    # Create a Connection String Builder
    $SQLConnectionStringBuilder = [System.Data.SqlClient.SqlConnectionStringBuilder]::new()

    # Set the Values if they are needed
    $SQLConnectionStringBuilder["Server"] = $ServerName

    # Set the Instance Name if it exists
    if ($InstanceName) {$SQLConnectionStringBuilder["Server"] = "{0}\{1}" -f $InstanceName, $SQLConnectionStringBuilder.Server}

    # Set the Server Port if included
    if ($ServerPort) {$SQLConnectionStringBuilder["Server"] = "{0},{1}" -f $SQLConnectionStringBuilder.Server, $ServerPort}

    # Set the Database Name
    $SQLConnectionStringBuilder["Initial Catalog"] = $DatabaseName

    # Set Intergrated Security only if the Parameter set was used
    if (($PSName -eq 'WindowsLogin') -or ($PSName -eq 'WindowsLoginEncrypt')) {
        $SQLConnectionStringBuilder["Intergrated Security"] = $IntergratedSecurity
    }

    # Set the User Credentials if the Parameter set was used
    if (($PSName -eq 'ManualLogin') -or ($PSName -eq 'ManualLoginEncrypt')) {
        # Convert the Secure String into unmanaged Memory
        $bytestr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password) 
        # Convert into PlainText
        $PlaintextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bytestr) 
        # Set the Values
        $SQLConnectionStringBuilder["User Id"] = $Credential.UserName
        $SQLConnectionStringBuilder["Password"] = $PlaintextPassword
    }

    # Set the Trusted Connection
    $SQLConnectionStringBuilder["Trusted Connection"] = $TrustedConnection.IsPresent

    # If the Encrypt Parameter was specified, set the encrypt key value
    if (($PSName -eq 'ManualLoginEncrypt') -or ($PSName -eq 'WindowsLoginEncrypt')) { 
        $SQLConnectionStringBuilder["Encrypt"] =  $Encrypt.IsPresent
    }
        
    # Set the remainder of Booleen Operations
    $SQLConnectionStringBuilder["TrustServerCertificate"] = $TrustServerCertificate.IsPresent
    $SQLConnectionStringBuilder["MultipleActiveResultSets"] = $MultipleActiveResultSets.IsPresent
    $SQLConnectionStringBuilder["PersistSecurityInfo"] = $PersistSecurityInfo.IsPresent
    $SQLConnectionStringBuilder["Connection Timeout"] = $ConnectionTimeout.IsPresent

    # Create a DataTable that will be used in the response.
    $dataTable = [System.Data.DataTable]::new()

    # Create the Object and Pass the Connection String into the Constructor
    $SQLConnection = [System.Data.SqlClient.SqlConnection]::New($SQLConnectionStringBuilder.ConnectionString)
    #
    # Create the Command Object
    $SQLCommand = [System.Data.SqlClient.sqlcommand]::New($commandText, $SQLConnection)
    # Update the Query Timeout
    $SQLCommand.CommandTimeout = $xmlSQLConfig.QueryTimeout
    #
    # Clear the Errors
    $error.Clear()

    # Encase the SQL Statement in a Try Catch. Any errors are caught and the process is stopped.
    try {
        # Open the Connection
        $SQLConnection.Open()
    } catch {       
        Throw "Error. There was a problem opening the SQL Connection."
        Write-Error $_
    }
    # Try and Execute the SQL Query
    try {
        # Execute the SQL Query
        $SQLCommand.ExecuteNonQuery() | Out-Null
    } catch {
        Throw ("Error. There was a problem executing the SQL Statement: '{0}'." -f $commandText)
        Write-Error $_
    }
    # Has the Read Parmeter been specified?
    if ($InvokeRead) {
        try {
            # Call ExecuteReader()
            $reader = $SQLCommand.ExecuteReader()
            # Load the data into the DataTable Object
            $datatable.Load($reader)
        } catch {
            Throw ("There was a problem retriving records from the database. SQL Statement: '{0}'." -f $commandText)
            write-error $_
        }        
    }
    
    # Dispose of the SQL Objects
    $SQLCommand.Dispose | Out-Null
    $SQLConnection.Close | Out-Null
    $SQLConnection.Dispose | Out-Null

    # Return the Result
    Write-Output $datatable
}
#endregion Invoke-SQLQuery

#region Test-ObjectProperty
# Function to test if a Property exists in an Object
# Author: Michael Zanatta
#----------------------------------------------------------------------------------------------------
function Test-ObjectProperty() {
    #------------------------------------------------------------------------------------------------
    #------------------------------------------------------------------------------------------------
    param (
        [parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [Object]
        $object,
        [parameter(Mandatory, Position = 1)]
        [string[]]
        $property
    )

    $result = $true

    #
    # Use Get Member to Locate the Property. If the collection contains true then the property exists.
    # If not then it dosen't
    #

    forEach ($prop in $property) {
        try {
            # Return False if the Object is Null
            if ($object -eq $null) {
                $result = $false
            }
            # Validate the Object Type. If the object is a hashtable it will need to be handled differently.
            elseif (($object -is [System.Collections.Hashtable]) -or ($object.GetType() -like "*Dictonary*")) {
                # Process as a Dictionary Element
                if (-not($object.GetEnumerator().Name | Where-Object {$_ -eq $prop})) {
                    # Update the Result
                    $result = $false
                }
            } else {
                # Process as an PSObject
                if (-not($object | Get-Member -Name $prop -MemberType Properties, ParameterizedProperty)) {
                    # Update the Result
                    $result = $false
                }
            }
        } catch {
        }
    }

    Write-Output $result

}
#endregion Test-ObjectProperty

#=============================================================================================
#                                      Initialize Code
#=============================================================================================

# TO DO: Test-ObjectProperty needs to be fixed. Query String is served as dictonary
if (-not (Test-ObjectProperty -Object $Request.Query -Property ComputerName)) {
    # Let's log the Error
    Write-Error "The ComputerName key does not exist. Please try again."

    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = @{error = "The ComputerName Key/Value is empty. Please try again."}  
    })

    # Return
    return

}

#===========================================================================================
#                                            Main
#===========================================================================================


# Pull the SQL Password
$SQLPassword = (Get-AzKeyVaultSecret -VaultName BrisPug -Name brispugbotdemo).SecretValue

# Declare the Response Body
$responsebody = $null

# Define the SQL Query
# TO DO: ISSUE HERE WITH POSSIBILITY OF EXECUTING THE CODE TWICE DUE TO SERVICE RUNNING JOBS ASYNCHRONOUSLY
$SQLParams = @{
    CommandText = "SELECT GUID, InputCliXML FROM remote_code_execution WHERE (ComputerNameTarget = '{0}') AND (Status = 'Queued');" -f $Request.Query.ComputerName
    DatabaseName = "RemoteBotDatabase"
    ServerName = "tcp:brispug.database.windows.net"
    ServerPort = "1433"
    Credential = [pscredential]::New('brispugbotdemo', $SQLPassword)
    Encrypt = $true
    InvokeRead = $true
}

# 
# Invoke SQL Query to Get the Jobs

try {
    # Invoke the SQL Query
    $RequestedJobs = Invoke-SQLQuery @SQLParams
 
} catch {
    # Let's log the Error
    Write-Error $_.ErrorMessage
    # Invalidate the Response
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = @{error = "There was a problem recieving the PowerShell Jobs"}  
    })
    # Return back to the parent
    Return
}   

#
# Validate the Response

# Check for an Empty String (Nulls are not allowed)
$responsebody = @{ 
    jobs = $RequestedJobs.Where{$_.inputclixml -ne [String]::Empty()}
}

# Invalidate Jobs that haven't been submitted correctly. If they are bad
# send an "error" status back the SQL Server
$RequestedJobs.Where{$_.inputclixml -eq [String]::Empty()} | ForEach-Object {

    # SQL Parameters
    $SQLErrorParams = @{
        CommandText = "UPDATE remote_code_execution SET Status = 'error' WHERE GUID = '{0}';" -f $_.GUID
        DatabaseName = "RemoteBotDatabase"
        ServerName = "tcp:brispug.database.windows.net"
        ServerPort = "1433"
        Credential = [pscredential]::New('brispugbotdemo', $SQLPassword)
        Encrypt = $true
    }

    # Write the back response back to SQL
    Try {
        Invoke-SQL @SQLErrorParams
    } Catch {
        # Write Non-Terminating Error
        Write-Error $_.ErrorMessage                       
    }
    
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $responsebody
})


