using namespace System.Net
# AUTHORS: Michael Zanatta, Christian Coventry

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

#=============================================================================================
#                                      Functions
#=============================================================================================

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Test the Object Property
# TODO: Christian
# Region Test-ObjectProperty
if (-not (Test-ObjectProperty -Object $Request.Query -Property GUID)) {
    # Let's log the Error
    Write-Error "The GUID query key does not exist. Please try again."
    #Return an error
    $status = [HttpStatusCode]::BadRequest
    $responsebody = @{error = "The GUID query key does not exist. Please try again."}  

    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $status
        Body = $responsebody
    })

    # Return
    return

}
# End Region Test-ObjectProperty

# Get the GUID from the HTML query
$GUID = $Request.Query.GUID

#============================================================================================
#                                       SQL Query
#============================================================================================

# SQL Parameters
$SQLParams = @{
    CommandText = ("SELECT InputCLIXML, ComputerNameTarget, GUID, Status WHERE GUID = '{0}'" -f $GUID)
    DatabaseName = "RemoteBotDatabase"
    UserName = "";
    Password = "";
    InvokeRead = $true
}

# 
# Invoke SQL Query to Add to the Database

try {

    #$SQLResponse = Invoke-SQLQuery @SQLParams

    # Test how many results there are:
    if ($SQLResponse.Count -eq 0) {
        # SQLResponse Count is 0. No results are returned.
    } else if ($SQLResponse.Count -gt 1) {
        # $SQLResponse Count is greater then 1. Multiple Results are returned.
        # This is unexpected.

    } else {
        # $SQLResponse Count is equal to 1
    }

    
    


} catch {
    # Let's log the Error
    Write-Error $_
    # This if statement will execute if Test-ObjectProperty evaluates to be false
    $status = [HttpStatusCode]::BadRequest
    $responsebody = @{error = "There was a problem submitting the request"}    
}   

# Carry out the SQL Lookup.
# 1: NoGUID = 404
# TODO: Christian

# 2: GUID Exists:
# Status Codes:
# a) "In Progress"
# b) "Completed"
# c) "Why am I here. What's broken?"

# Returning the Infomation


# Test Some Properties
#https://www.google.com?peter=smith&newval=value
GUID=$GUID
#https://wwww.google.com?GUID=MEH
#Test the object property
#Carry out SQL lookup to check to see if GUID exists
#If GUID does not exist, send error 404
#GUID exists
#InputCLIXML, ComputerNameTarget, GUID, Status
# Filtering on Status
# IF Status -eq "In Progress" 
# ELSEIF Status -eq "Completed"
# ELSE ("WHY AM I HERE?")
# Returning the Information
#


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

#==============================================================================================
#                                     Functions Again
#==============================================================================================



# region Test-Property
# Function to test if a Property exists in an Object
# Author: Michael Zanatta
#----------------------------------------------------------------------------------------------------
function Test-ObjectProperty() {
    #------------------------------------------------------------------------------------------------
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [AllowNull()]
        [Object]
        $object,
        [parameter(Mandatory = $true, Position = 1)]
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

# Declare the Response Body
$responsebody = $null



#================================================================================================
#                                              Main?
#================================================================================================

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

if ($name) {
    $status = [HttpStatusCode]::OK
    $body = "Hello $name"
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = "Please pass a name on the query string or in the request body."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
