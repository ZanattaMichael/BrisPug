#
# DEMO: PSOBJECT vs PSCUSTOM OBJECT
#

#Performance of PSObject
$ServerNumbers = 1..300000
$List = [System.Collections.ArrayList]::New()

$PSObjectScriptBlock = {
    foreach ($ServerNumber in $ServerNumbers)
    {
        $ServerList.Add(
            [PSObject]@{
                Name="Server$($ServerNumber)"; 
                RoleCount = (Get-Random -Minimum 1 -Maximum 2)
            }
        )

    }
}

Measure-Command -Expression $PSObjectScriptBlock

#Performance of PSCustomObject
$ServerNumbers = 1..300000
$List = [System.Collections.ArrayList]::New()

$PSCustomObjectScriptBlock = {
    foreach ($ServerNumber in $ServerNumbers)
    {
        $ServerList.Add(
            [PSCustomObject]@{
                Name="Server$($ServerNumber)"
                RoleCount = (Get-Random -Minimum 1 -Maximum 2)
            }
        )
    }
}

Measure-Command -Expression $PSCustomObjectScriptBlock
