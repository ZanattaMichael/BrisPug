
#
# This class create's a WinForm from that display's an Interactive Internet explorer page.
# Once the URI has met the regex criteria. The form window will be automatically closed.
#
# Source: http://johnliu.net/blog/2015/10/posting-to-office-365-onenote-via-powershell
#
class InternetExplorerForm {

    # Define the URI
    [Uri]$URI
    # Define the Return URI
    [String]$Global:ReturnURI
    # Define the RegexString
    [String]$Global:RegexMatchString

    # Define the Form
    hidden $Form = $(New-Object -TypeName System.Windows.Forms.Form)
    # Define the WebBrowser
    hidden $WebBrowser = $(New-Object -TypeName System.Windows.Forms.WebBrowser)

    InternetExplorerForm() {
        # Set the Form Dimentions
        $this.Form.Width = 440;
        $this.Form.Height = 640;
        # Set the Browser Dimensions
        $this.WebBrowser.Width = 420;
        $this.WebBrowser.Height = 600;

    }

    InternetExplorerForm([Uri]$uri, [String]$regexString) {
        # Set the URI to be this
        $this.URI = $uri
        # Set the Regex Maching String
        $Global:RegexMatchString = $regexString

        # Set the Form Dimentions
        $this.Form.Width = 440;
        $this.Form.Height = 640;

        # Set the Browser Dimensions
        $this.WebBrowser.Width = 420;
        $this.WebBrowser.Height = 600;

    }

    ShowBrowserDialog() {
        # Browse
        $this.Browse();

    }

    ShowBrowserDialog([Uri]$uri, [string]$regex) {
        # Set the URI and then Browse
        $this.URI = $uri;
        $this.Browse();

    }   

    Hidden Browse() {

        # Set the URI
        $this.WebBrowser.Url = $this.URI
        # Supress Errors. This is becuase the Callback URL won't exist.
        # Were just capturing the string. Hehehehe
        $this.WebBrowser.ScriptErrorsSuppressed = $true

        # Create a Link to the Browser and the Local Form since $this refers to the local class.
        $WinForm = $this.Form

        #
        # Define the Event that will be Triggered when the Document Loads
        $Event_DocumentCompleted  = {
            # Since this code is being executed on a different class, we need to change the way we write information back.
            # Write to the Return URI
            $Global:ReturnURI = $this.Url.AbsoluteUri
            # Dispose of the Form if the response is specified. This regex is looking for:
            #
            # Valance Authentication: ("token?x_a=" AND "&x_b=" AND "&x_target=") OR ("error")
            # OAuth 2.0 Authentication: code=auth-code.0bM6M5T7kTNqZ2Un0qzb_k4ZYPbXf19-3Zv84ZWEWAA    
            #        
            write-host $this.Url.AbsoluteUri        
            if ($Global:ReturnURI -match $Global:RegexMatchString) {
                # Close the Form
                $WinForm.Close();
            }
        }
        # Add the Event to the Browser
        $this.WebBrowser.Add_DocumentCompleted($Event_DocumentCompleted)

        #
        # Forms Controls
        $this.form.Controls.Add($this.WebBrowser)
        # Add to the Form Event to Show the Form
        $this.form.Add_Shown(
            {
                $this.Activate()
            }
        )
        # Activate!
        try {
            $this.form.ShowDialog() | Out-Null    
        } Catch {
            Write-Warning $_
        }            
        # Dispose of it.
        $this.Dispose()
    }

    Dispose() {
        # Dispose of the Object
        # 
        $this.WebBrowser.Dispose()
        $this.Form.Close()
        $this.Form.Dispose()

    }

}
