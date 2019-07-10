# Author: My Boy @GlenSarti
#TODO: Update Code to Return Message Block
Function Invoke-TrapWebErrors([scriptblock]$sb) {
    # Unfortunately Invoke-WebRequest throws errors for 4xx/5xx errors, but we may want
    # the raw HTML response e.g. for testing specific error codes.  In this case, run
    # an arbitrary ScriptBlock and trap WebExceptions and return the response object
    $result = try {
      & $sb
    } catch {

      # If a HTTP Response Message was sent back
      if ($_.ErrorDetails.Message) {
          return $_.ErrorDetails.Message
      }

      # Throw a Terminating Error
      throw $_

    }
  
  }