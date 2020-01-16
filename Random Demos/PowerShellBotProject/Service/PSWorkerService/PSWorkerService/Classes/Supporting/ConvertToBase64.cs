#
# New-Object
#
$obj = New-Object -TypeName psobject
$obj | Add-Member -MemberType NoteProperty -Name PropertyName -Value "Test" -Force
$obj | Add-Member -MemberType NoteProperty -Name PropertyName2 -Value "Test2" -Force
$obj | Add-Member -MemberType NoteProperty -Name PropertyName3 -Value "Test3" -Force

#
# Hash Table
#
$HashTable = @{
    Properties = "Hello"
    Powershell = "Yep"
    Other = $null
}

# Define a Quick String
$String = "This is a string kjhkjhjknkjhjkhhjk"

# String
If ($String -eq "This is a string") {
    $HashTable.Add("InSync", "Technologies")
} elseif ($String -eq "This is not a string") {
    Write-Host "Yea Nah"
}

#
# Splatting with HashTable

$params = @{
    LiteralPath = "C:\Windows"

}

# Traditional way of running cmdlets
Get-ChildItem -LiteralPath C:\Windows
Get-ChildItem @Params

#
# Version 3 Hash Tables
#

$v3HashTable = [PSCustomObject]@{
    Name = "Value"
}

#
# Add-Type
#

Add-Type @"

    using System;

    public class myClass {

        public String property = "This is a string";
        
        public myClass() {
        }
    }

"@

#
# Select Object
#
$Process = Get-Process | Select-Object id, name
# Select Expression
$Process = Get-Process | Select-Object id, name, @{Name="ProcessExtension"; Expression={"$($_.Name).exe"}}
# Select Expression - Shorthand
$Process = Get-Process | Select-Object id, name, @{N="ProcessExtension"; E={"$($_.Name).exe"}}