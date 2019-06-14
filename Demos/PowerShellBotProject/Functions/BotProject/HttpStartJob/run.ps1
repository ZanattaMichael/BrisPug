using namespace System.Net
using namespace System.Data.SqlClient

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Write-Verbose $Request

# https://devblogs.microsoft.com/scripting/hey-scripting-guy-how-do-i-add-help-information-for-windows-powershell-parameters/

<# POST method: $req
Authors: Michael Zanatta, Christian Coventry
------------------------------------------------------------------------------------
Statuses that will be used during execution:
    In Progress - Script has been sent to endpoint. Awaiting results.
    Completed - Script has finished executing and results have been received. 
    Failed - Script has finished executing or thrown an error. No results received. 

REQUEST:
{
    "ComputerName":  "Test01",
    "Code":  "Base 64 encoded CliXML"
}

RESPONSE:
{
    "Success" {
        "GUID":  "45f13471-9eea-4463-8b5d-96aa90e02de6",
        "Status":  "In Progress"
    }
}
#>

# ==========================================================================================
#                                          Functions
# ==========================================================================================

# Functions to Load

# region Test-Property
# Function to test if a Property exists in an Object
# Author: Michael Zanatta
#----------------------------------------------------------------------------------------------------
function Test-ObjectProperty() {
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
            elseif ($object -is [System.Collections.Hashtable]) {
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
# endregion Test-Property

#======================================================================================
#                                            SQL Query
#======================================================================================


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

# ========================================================================================
#                                          Main
# ========================================================================================
wait-debugger

# Create GUID
$GUID = [GUID]::NewGuid().GUID

# Pull the SQL Password
$SQLPassword = (Get-AzKeyVaultSecret -VaultName BrisPug -Name brispugbotdemo).SecretValue

# Get the Body of the HTML Request
$requestBody = $Request.Body | ConvertFrom-Json

# Declare the Response Body
$responsebody = $null

# Validate the Input
if (-not (Test-ObjectProperty -object $requestBody -property ComputerName, Code)){
    # Log 
    Write-Error "Missing ComputerName, Code Property"

    # This if statement will execute if Test-ObjectProperty evaluates to be false
    $status = [HttpStatusCode]::BadRequest
    $responsebody = @{error = "Missing ComputerName, Code Property."}

} else {


    $SQLParams = @{
        CommandText = ("INSERT INTO [dbo].[remote_code_execution] (InputCLIXML, ComputerNameTarget, GUID, Status) VALUES ('{0}', '{1}', '{2}', '{3}')" -f `
                        $requestBody.Code, $requestBody.ComputerName, $GUID, "Queued")
        ServerName = "tcp:brispug.database.windows.net"
        ServerPort = "1433"
        DatabaseName = "RemoteBotDatabase"
        Credential = [pscredential]::New('brispugbotdemo', $SQLPassword)
        Encrypt = $true
    }

    # 
    # Invoke SQL Query to Add to the Database

    try {

        Invoke-SQLQuery @SQLParams

        #
        # Return object. Contains information that will returned to the sender. 
        $status = [HttpStatusCode]::OK
        $responsebody = @{
            success = @{
                GUID = $GUID
                Status = "In Progress"
            }
        }
        
    } catch {
        # Let's log the Error
        Write-Error $_
        # This if statement will execute if Test-ObjectProperty evaluates to be false
        $status = [HttpStatusCode]::BadRequest
        $responsebody = @{error = "There was a problem submitting the request"}    
    }   

}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $responsebody
})
