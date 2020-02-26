Function Test-MVPStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]
        $Name
    )

    process {

        $params = @{
            Uri = 'https://www.mvp.microsoft.com/en-us/MvpSearch?kw={0}' -f [System.Web.HttpUtility]::UrlEncode($Name)
        }

        Write-Output (Invoke-WebRequest @params).Content -notmatch '(No results found for the selected query.)'
    }
}

<#
PSv7.0-rc.3 -> C:\Users\Michael.Zanatta>Test-MVPStatus -Name "Michael Zanatta"
False
PSv7.0-rc.3 -> C:\Users\Michael.Zanatta>Test-MVPStatus -Name "Don Jones"
True
PSv7.0-rc.3 -> C:\Users\Michael.Zanatta>"Michael Zanatta","Don Jones" | Test-MVPStatus
False
True
#>