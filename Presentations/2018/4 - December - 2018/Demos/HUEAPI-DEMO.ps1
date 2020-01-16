#
# Developer Website: https://developers.meethue.com/develop/hue-api/lights-api/#set-light-state

#
# HUE IP Address
$HUEControllerIPAddress = ""
$HUEControllerIPAddress = "http://10.4.200.9"

#
# Step 1 we must authenticate with the controller. HUE uses a physical security through a button press


#
# Authenticate with the HUE Controller
#

# Body of the Request
$RequestBody = @{
    devicetype="brispug_demo_stream#1"
}


# Keep Authenticating until we press the button
Do {

    # Authenticate with the Controller
    $UserDetails = Invoke-RestMethod -Method Post -Uri ("{0}/api" -f $HUEControllerIPAddress) -Body ($RequestBody | ConvertTo-Json) -ContentType "application/json"

    # Not the best way to test for the property, but test for the error property.
    if ($UserDetails.success) {
        # Break the Loop
        Break
    }

    # Sleep for 10 Seconds and Loop
    Start-Sleep -Seconds 10

    # Write a Warning to the Console
    Write-Warning "Button Press was Missed. Please try again."

} Until (-not($UserDetails.Error))

#
# Enumerate all the Lights that are registered
#

$params = @{
    uri="{0}/api/{1}/lights" -f $HUEControllerIPAddress, $UserDetails.Success.username
    method="Get"
    ContentType="application/json"
}

# Invoke the REST Method
$EnumeratedLights = Invoke-RestMethod @params

#
# Lets get some infomation about the Light
#

$params = @{
    uri="{0}/api/{1}/lights/7" -f $HUEControllerIPAddress, $UserDetails.Success.username
    method="Get"
    ContentType="application/json"
}

# Invoke the REST Method
$EnumeratedLights = Invoke-RestMethod @params

#
# Let's turn the light off
#

$params = @{
    uri="{0}/api/{1}/lights/7/state" -f $HUEControllerIPAddress, $UserDetails.Success.username
    method="PUT"
    ContentType="application/json"
    Body=@{
        on=$false
    } | ConvertTo-Json
}

# Invoke the REST Method
$Result = Invoke-RestMethod @params


#
# Let's turn the light on
#

$params = @{
    uri="{0}/api/{1}/lights/7/state" -f $HUEControllerIPAddress, $UserDetails.Success.username
    method="PUT"
    ContentType="application/json"
    Body=@{
        on=$true
    } | ConvertTo-Json
}

# Invoke the REST Method
$Result = Invoke-RestMethod @params


#
# Let's change the colour of the Lights
#


# Set the Red Light

$red = 65535

# Set the Green Light

$green = 25500 

# Set the Blue Light

$blue = 46920

$params = @{
    uri="{0}/api/{1}/lights/7/state" -f $HUEControllerIPAddress, $UserDetails.Success.username
    method="PUT"
    ContentType="application/json"
    Body= @{
    	hue = $blue
    	on = $true
    	bri = 256
        transitiontime = 20
    } | ConvertTo-Json
}

$result = Invoke-RestMethod @params

#
# We can do a test with pings now.
#

Do {
    
    $result = Test-NetConnection -ComputerName 10.4.200.9 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

    # Test if the Ping Failed
    if (-not($result.PingSucceeded)) {

        # Let's Alert with a Random Colour
        $params = @{
            uri="{0}/api/{1}/lights/7/state" -f $HUEControllerIPAddress, $UserDetails.Success.username
            method="PUT"
            ContentType="application/json"
            Body= @{
    	        alert = "lselect"
    	        hue = (Get-Random -Minimum 0 -Maximum 65535)
    	        on = $true
    	        bri = 256              
            } | ConvertTo-Json
        }

        # Invoke the Request
        $Result = Invoke-RestMethod @params -Verbose

        # Sleep for 30 Seconds
        Start-Sleep -Seconds 30
    }

} Until ($Forever)

#
# Finally for Fun. Let's flash some lights with some music
#

Start-Process iexplore.exe "https://www.youtube.com/watch?v=dvgZkm1xWPE"

Do {

        # Let' Set a Random Colour
        $params = @{
            uri="{0}/api/{1}/lights/7/state" -f $HUEControllerIPAddress, $UserDetails.Success.username
            method="PUT"
            ContentType="application/json"
            Body= @{
    	        hue = (Get-Random -Minimum 0 -Maximum 65535)
    	        on = $true
    	        bri = 255              
            } | ConvertTo-Json
        }

        # Invoke the Request
        $Result = Invoke-RestMethod @params -Verbose

         # Sleep
        Start-Sleep -Milliseconds 100

         # Let's turn the lights off
        $params = @{
            uri="{0}/api/{1}/lights/7/state" -f $HUEControllerIPAddress, $UserDetails.Success.username
            method="PUT"
            ContentType="application/json"
            Body= @{
    	        on = $false            
            } | ConvertTo-Json
        }

        # Invoke the Request
        $Result = Invoke-RestMethod @params -Verbose
        

        # Sleep for 250 Seconds
            
        Start-Sleep -Milliseconds 250

} Until ($Forever)