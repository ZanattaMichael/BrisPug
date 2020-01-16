
#
# Data Types
#

#
# JSON Data Type

# Get the Process
$Collection = Get-ChildItem -LiteralPath C:\Windows -File | Select FullName, Id, Extension

# Convert the Object into JSON
$jsonString = $Collection | ConvertTo-Json | Out-File "C:\temp\JsonFile.json"

#
# XML Data Types

# Convert into a XML Data Type
$xmlCollection = $Collection | ConvertTo-Xml | Out-String
# Save the XML File
$xmlCollection.Save("C:\Temp\XMLFile.xml")

