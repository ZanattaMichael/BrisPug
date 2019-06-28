# Author: My Boy @GlenSarti
Function Invoke-TrapWebErrors([scriptblock]$sb) {
    # Unfortunately Invoke-WebRequest throws errors for 4xx/5xx errors, but we may want
    # the raw HTML response e.g. for testing specific error codes.  In this case, run
    # an arbitrary ScriptBlock and trap WebExceptions and return the response object
    $result = try {
      & $sb
    } catch [System.Net.WebException] {
      # Windows PowerShell raises a System.Net.WebException error
      $_.Exception.Response
    } catch {
      # PowerShell Core raises a stadard PowerShell error class with the exception within.
      if ($_.Exception.GetType().ToString() -eq 'Microsoft.PowerShell.Commands.HttpResponseException') {
        $_.Exception.Response
      } else {
        Throw $_
      }
    }
  
    $result
  }