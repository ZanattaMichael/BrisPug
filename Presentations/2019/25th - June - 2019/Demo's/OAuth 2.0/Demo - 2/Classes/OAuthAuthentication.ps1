Class OAuthAuthentication:ICloneable {

    #
    # Define the D2L Authentication URI's
    #
    [String]$server_authentication_uri = "https://github.com/login/oauth"
    [String]$server_authentication_code_endpoint = "{0}/authorize" -f $this.server_authentication_uri
    [String]$server_authentication_token_endpoint = "{0}/access_token" -f $this.server_authentication_uri

    #
    # Ouath Configuration
    #   
    [String]$client_id = $null
    [String]$client_secret = $null
    [String]$client_scope = $null
    [String]$client_access_token = $null
    [String]$client_refresh_token = $null
    [String]$client_token_expires_in = $null
    [Long]$client_token_issue_time = -1
    [String]$client_token_type = $null

    [String]$server_callback_url = $null
    
    #
    # URI Response
    #
    [Uri]$client_authentication_response

    #
    # RegEx String    
    #
    #[String]$oauth_authentication_regex_string = "https:\/\/[^&]*\/\?code=auth-code[^&]*"   
    [String]$oauth_authentication_regex_string = "https:\/\/[^&]*\/\?code=[^&]*"
    #
    # Define the IE Form
    #
    [InternetExplorerForm]$internetExplorerForm

    #
    # Other Static Items
    #
    [String]$response_type_code = "code"
    #
    # OAuth Grant Types
    #
    [String]$grant_type_authorization_code = "authorization_code"
    [String]$grant_type_refresh_token = "refresh_token"

    # Set Authentication
    [String]$Authenticated = $false
   
    #
    # Default Constructor
    #
    OAuthAuthentication() {
        
    }

    #
    # Create a Copy of the Object
    #
    [Object] Clone () {

        $NewOAuth = [OAuthAuthentication]::New()

        foreach ($Property in ($this | Get-Member -MemberType Property))
        {
            $NewOAuth.$($Property.Name) = $this.$($Property.Name)
        }

        return $NewOAuth
    }  

    #
    # Create a new Authentication Object
    #
    OAuthAuthentication([String]$client_id, [String]$client_secret, [String]$server_callback_url, [String]$client_scope) {
        
        $this.client_id = $client_id
        $this.client_secret = $client_secret
        $this.server_callback_url = $server_callback_url
        $this.client_scope = $client_scope

        $this.client_access_token = $null
        $this.client_refresh_token = $null
        $this.client_token_expires_in = $null
        $this.client_token_issue_time = 0
        $this.client_token_type = $null

        # Get the Authentication Code
        $this.GetAuthenticationCode()
        # Get the Access Token
        $this.GetAccessToken()
        # Enable Authentication
        $this.Authenticated = $true
    }
    #
    # Retrive the Authentication Code from the Authentication Endpoint.
    #
    hidden GetAuthenticationCode() {

        # Define URI Parameters
        $URIParams = @{
            client_id = $this.client_id
            scope = $this.client_scope
        }

        #
        # Authenticate and Retrive the Authentication Code
        #

        # Build the URI String

        $UriBuilder = [URIBuilder]::New($this.server_authentication_code_endpoint, $URIParams)
        # Build the Internet Explorer Form
        
        $this.internetExplorerForm = [InternetExplorerForm]::New($UriBuilder.uri, $this.oauth_authentication_regex_string)
        # Browse to the Form
        $null = $this.internetExplorerForm.ShowBrowserDialog()

        # Validate that there was a ReturnURI
        if (-not([String]::IsNullOrWhiteSpace($Global:ReturnURI))) {
            # Capture the Return URI
            $this.client_authentication_response = [Uri]::new($Global:ReturnURI)        
        }

    }
    #
    # Get the Access Token from the Authentication Code
    #
    GetAccessToken() {

        #
        # Format the REST Query
        #$params = @{
        #  Uri = $this.server_authentication_token_endpoint
        #   Body = "grant_type={0}&{1}&redirect_uri={2}" -f [System.Uri]::EscapeDataString($this.grant_type_authorization_code),
        #                                                    $this.client_authentication_response.Query.Substring(1,$this.client_authentication_response.Query.Length - 1), 
        #                                                    [System.Uri]::EscapeDataString($this.server_callback_url)
        #    ContentType = "application/x-www-form-urlencoded" ;
        #    Headers = @{Authorization = "Basic {0}" -f (("{0}:{1}" -f $this.client_id, $this.client_secret ) | ConvertTo-Base64)} ;
        #    ErrorAction = "Stop";
        #    Method = "POST";
        #}

        $params = @{
            Uri = $this.server_authentication_token_endpoint
            Body = "client_id={0}&client_secret={1}&{2}" -f `
                        $this.client_id, `
                        $this.client_secret, `
                        $this.client_authentication_response.Query.Substring(1,$this.client_authentication_response.Query.Length - 1)
            ContentType = "application/x-www-form-urlencoded" ;
            ErrorAction = "Stop";
            Method = "POST";
        }        

        try {
            # Invoke a Token Request
            $webrequest = $this.InvokeTokenRequest($params) 
        } catch {
            Throw $_
        }   

        # Update the Object
        $this.UpdateObject($webrequest)                

    }
    #
    # Refresh the Token
    #
    RefreshToken() {

        #
        # Test for the Refresh Token. If the token is not present, the authentication process will need to be restarted with the access token.

        if (Test-ObjectProperty -object $this -property client_refresh_token) {

            #
            # Format the REST Query
            $params = @{
                Uri = $this.server_authentication_token_endpoint
                Body = "grant_type={0}&refresh_token={1}" -f [System.Uri]::EscapeDataString($this.grant_type_refresh_token),
                                                             [System.Uri]::EscapeDataString($this.client_refresh_token)
                ContentType = "application/x-www-form-urlencoded" ;
                Headers = @{Authorization = "Basic {0}" -f (("{0}:{1}" -f $this.client_id, $this.client_secret ) | ConvertTo-Base64)} ;
                ErrorAction = "Stop";
                Method = "POST";
            }           

            try {
                # Invoke a Token Request
                $webrequest = $this.InvokeTokenRequest($params) 
            } catch {
                Throw $_
            }

            # Update the Object
            $this.UpdateObject($webrequest)

        } else {

            # Re-Authenticate the Client and Fetch an Access Token. This process is interactive.
            $this.GetAuthenticationCode()

        }
    }

    #
    # Perform a Token Request
    #
    Hidden [PSCustomObject] InvokeTokenRequest([System.Collections.Hashtable] $params) {
        
        #
        # Fetch the Token
        try {
            
            # Invoke the WebRequest
            $webRequest = Invoke-RestMethod @params

        } catch {   
            Throw $_        
        }
        
        return [PSCustomObject]$webRequest
    }

    #
    # Updates the Object with the new Rest Details
    #
    Hidden UpdateObject([PSCustomObject] $webRequest) {

        # Since we cannot be 100% sure of the response, nest inside a try/catch
        try {
            # The response is a URL encoded response. This needs to be formatted. Convert the Query String into an Object
            $decodedWebRequest = $webRequest -split "&" | ForEach-Object -Begin {$col = @()} -End {Write-Output $col} {         
                $col += [PSObject]@{
                    $($_.Split("=")[0]) = $_.Split("=")[1]
                } 
            }
        } catch {
            Throw $_
        }

        #
        # Set the Token Information
        $this.client_access_token = $decodedWebRequest.access_token
        $this.client_token_type = $decodedWebRequest.token_type
        $this.client_scope = $decodedWebRequest.scope
        $this.client_token_expires_in = $webRequest.expires_in
        # Set the Issue Date
        $this.client_token_issue_time = [DateTime]::UtcNow.Ticks; 
        # Set the Authentication to True
        $this.Authenticated = $true;


        #
        # Validate if the Refresh Token is Present.
        if (-not(Test-ObjectProperty -object $webRequest -property refresh_token)) {
            # Display a warning, since it's not terminating
            Write-Warning "The refresh_token is missing. To get issued a new token, the module will need to re-authenticate."
        } else {
            #
            # Set the Refresh Token
            $this.client_refresh_token = $webRequest.refresh_token
        }

    }
  
}