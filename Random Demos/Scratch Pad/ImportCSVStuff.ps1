#
# Define Requires Statment. You don't need to load AD. The script won't run without the AD Module.
# PS 4.0 and up.

#Requires -Version 4.0
#Requires -Modules ActiveDirectory

#region Write-Log
# Function Write-Log
# Descrption: Create a logging function that writes to console, and colour codes according to whether it's an Error or not
function Write-Log {

    param (
        [parameter(Mandatory = $true, Position = 0)]
        [String]
        $Content,
        [parameter(Mandatory = $false, Position = 1)]
        [ValidateSet("Error","Warning","Info", "Verbose")] 
        [String]
        $Type="Info"
    )

    # Get the Date
    $CurrentTime = Get-Date -f HH:mm:ss

    # Build out the Logging String
    $LogItem = "[{0}] {1} - {2}" -f $CurrentTime, $Type.ToUpper(), $Content

    # Use Write-Error (Not Terminating) / Write-Warning and Write-Host
    if ($Type -eq "Error") {
        Write-Error $LogItem
    } elseif ($Type -eq "Warning") {
        Write-Warning $LogItem
    } elseif ($Type -eq "Verbose") {
        Write-Verbose $LogItem
    } else {
        Write-Host $LogItem
    }

}

#
# Add Type and Load the Systems Forms
Add-Type -AssemblyName System.Windows.Forms
$csvpath = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }

# Show the Dialog
$null = $csvpath.ShowDialog()

#
# Import the CSV File

# Update Log
Write-Log -Content "Importing CSV File:"

# Try and Import the CSV File
try {
    # Always Use -LiteralPath
    $CSV = Import-CSV -LiteralPath $csvpath.FileName
} catch {
    # An error occured.
    Write-Log -Content "An Error Occured Attempting to Import the CSV File. Terminating:" -Type Error
    Write-Log -Content $_.Exception -Type Error
    Throw $_
}

