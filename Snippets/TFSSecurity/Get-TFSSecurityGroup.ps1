
Function Get-TFSSecruityGroup {
    [CmdletBinding(DefaultParameterSetName = 'Server')]
    param(
        [Parameter(
            Mandatory,
            ParameterSetName = 'Server'
        )]
        [String]
        $ServerURL,

        [Parameter(
            Mandatory,
            ParameterSetName = 'Collection'
        )]
        [String]
        $CollectionURL
    )

    $ParameterType = $(
        if ($PSCmdlet.ParameterSetName -eq 'Server') { 'Server:' }
        else {'Collection:'}
    )

    $OutputString = .\TFSSecurity.exe /g /$ParameterType$ServerURL$CollectionURL
    Format-TFSSecurityGroup -InputString $OutputString


}

Function Format-TFSSecurityGroup {
    param(
        [Parameter(mandatory, ValueFromPipeline)]
        [Object]
        $InputString
    )


    # Regex Header
    $RegexHeader = '(^.*: )|(^.*:)'

    # Clean up the input
    $sanitizedText = ($InputString | Select-String -Pattern '^(SID: )|(DN:)|(Identity type: )|(Group type:)|(Project scope:)|(Display name:)|(Description:)' -AllMatches) -replace '^ *', ''
    # Create the Object
    0..$sanitizedText.Length | Where-Object {$sanitizedText[$_] -like 'SID:*'} | ForEach-Object {
        
        $obj = @{}
        switch -wildcard ($sanitizedText[$_..($_+6)]) {        
            "SID*" { $obj.SID = $_ -replace $RegexHeader, '' }
            "DN*" { $obj.DistinguishedName = $_ -replace $RegexHeader, '' }
            "Identity type:*" { $obj.IdentityType = $_ -replace $RegexHeader, '' }
            "Group type:*" { $obj.GroupType = $_ -replace $RegexHeader, '' }
            "Project scope:*" { $obj.ProjectScope = $_ -replace $RegexHeader, '' }
            "Display name:*" { $obj.DisplayName = $_ -replace $RegexHeader, '' }
            "Description:*" { $obj.Description = $_ -replace $RegexHeader, '' }
        }
        [PSCustomObject]$obj

    }

}
