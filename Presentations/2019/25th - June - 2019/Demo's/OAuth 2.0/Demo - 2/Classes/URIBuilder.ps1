
Class URIBuilder {

    [Uri]$URI

    UriBuilder() {

    }

    UriBuilder([String]$HostName, [System.Collections.Hashtable]$ParameterSet) {

        # Define the Parameter Set String
        $ParameterSetString = ""

        # Build out the string according to the ParameterSet
        ForEach ($Parameter in $ParameterSet.Keys) {
            $ParameterSetString += "{1}={2}&" -f $ParameterSetString, [string]$Parameter, $ParameterSet[$Parameter]
        }  
        # Remove the Trailing &
        $ParameterSetString = $ParameterSetString.Substring(0,$ParameterSetString.Length-1)

        # Create the URI        
        $this.URI = [URI]::New(("{0}?{1}" -f $HostName, $ParameterSetString))
    }

    Build([Uri]$HostName, [System.Collections.Hashtable]$ParameterSet) {
        
        # Define the Parameter Set String
        $ParameterSetString = ""

        # Build out the string according to the ParameterSet
        ForEach ($Parameter in $ParameterSet.Keys) {
            $ParameterSetString += "{1}={2}&" -f $ParameterSetString, [string]$Parameter, $ParameterSet[$Parameter]
        }  
        # Remove the Trailing &
        $ParameterSetString = $ParameterSetString.Substring(0,$ParameterSetString.Length-1)

        #
        # Create the URI
        
        # If there is no existing query in the URI, then build a new one.
        if ([String]::IsNullOrEmpty($HostName.query)) {
            $this.URI = [URI]::New(("{0}?{1}" -f $HostName.OriginalString, $ParameterSetString))
        } else {
            # Otherwise append the existing query to the URI
            $this.URI = [URI]::New(("{0}&{1}" -f $HostName.OriginalString, $ParameterSetString))
        }
        

    }

}