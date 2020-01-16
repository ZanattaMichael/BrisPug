
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
    "GUID":  "45f13471-9eea-4463-8b5d-96aa90e02de6",
    "Status":  "In Progress"
}
#>

# ==========================================================================================
#                                          Functions
# ==========================================================================================

# Functions to Load


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
            elseif ($object -is [System.Collections.Hashtable]) {
                # Process as a PS HashTable Element
                if (-not($object.GetEnumerator().Name | Where-Object {$_ -eq $prop})) {
                    # Update the Result
                    $result = $false
                }
            }
            elseif ($object.GetType().Name -like "*Dictionary*") {
                # Process as a Dictonary Element
                if (-not($object.Keys.Where{$_ -eq $prop})) {
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

#
# Server=tcp:brispug.database.windows.net,1433;Initial Catalog=RemoteBotDatabase;Persist Security Info=False;User ID={your_username};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
# TODO: ADD USER NAME AND PASSWORD

    Param (
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline=$true)]
        [String]$commandText,
        [parameter(Mandatory = $true, Position = 1)]
        [String]$ServerName,
        [parameter(Mandatory = $true, Position = 2)]
        [String]$DatabaseName,
        [parameter(Mandatory = $false, Position = 3)]
        [String]$InstanceName,        
        [parameter(Mandatory = $false, Position = 4)]
        [Switch]$InvokeRead,
        [parameter(Mandatory = $true, Position = 5)]
        [String]$Username,
        [parameter(Mandatory = $true, Position = 6)]
        [String]$Password
    )
    # Create a DataTable that will be used in the response.
    $dataTable = New-Object System.Data.DataTable
    #
    # Build the Connection String
    if ($InstanceName) {
        $SQLConnectionString = "Server=tcp:{0}\{1};Database={2};User ID={3};Password={4};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;" -f $ServerName, $InstanceName, $DatabaseName, $Username, $Password
    } else {
        $SQLConnectionString = "Server=tcp:{0};Database={1};User ID={2};Password={3};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;" -f $ServerName, $DatabaseName, $Username, $Password
    }

    # Create the Object and Pass the Connection String into the Constructor
    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $SQLConnectionString
    #
    # Create the Command Object
    $SQLCommand = New-Object System.data.sqlclient.sqlcommand $commandText, $SQLConnection
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

# Create GUID
$GUID = [GUID]::NewGuid().GUID

# Get the Body of the HTML Request
$requestBody = Get-Content $req -Raw | ConvertFrom-Json

# Validate the Input
if (-not (Test-ObjectProperty -object $requestBody -property ComputerName, Code)){
   
    # This if statement will execute if Test-ObjectProperty evaluates to be false
    $Status = "Failed"
    Write-Host $Status
}

# 
# Invoke SQL Query to Add to the Database

# SQL Parameters
$SQLParams = @{

    CommandText = ("INSERT INTO [dbo].[remote_code_execution] (InputCLIXML, ComputerNameTarget, GUID, Status) VALUES ({0}, {1}, {2}, {3})" -f `
                    $requestBody.Code, $requestBody.ComputerName, $GUID, "In Progress")
    DatabaseName = "RemoteBotDatabase"
    UserName = "";
    Password = "";
}

#
# Return object. Contains information that will returned to the sender. 

$ReturnObj = @{
    GUID = $GUID
    Status = "In Progress"
}
# Return the results to the sender. 

Return ($ReturnObj | ConvertTo-Json)




