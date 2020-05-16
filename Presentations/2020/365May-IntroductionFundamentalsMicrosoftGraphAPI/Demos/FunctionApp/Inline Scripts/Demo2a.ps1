# Start the azure function app


func host start

#
# We are going to target some REST api endpoints so we can see the URI and Methods in motion
# Don't worry about Invoke-RestMethod, however I want you to focur on the URI and Methods here!

# Let's Call the API Endpoint using a standard get request.
Invoke-RestMethod -Uri "http://localhost:7071/api/Demo2a" -Method Get

# It's expecting a Name in the Query String. Let's do that now!
Invoke-RestMethod -Uri "http://localhost:7071/api/Demo2a?Name=Michael Zanatta" -Method Get

# Let's now suss out the "http://localhost:7071/api/Demo2" API Endpoint.
# This endpoint only accepts HTTP POST Methods.
# So let's run a Get to it!

Invoke-RestMethod -Uri "http://localhost:7071/api/Demo2b" -Method Get
# What do we get back?
# A 404 Error! The client has entered an incorrect location.

# Let's give it what it wants and do a POST Method and Add a Body
$Body = ConvertTo-Json @{
    Name = "Barry White"
}
Invoke-RestMethod -Uri "http://localhost:7071/api/Demo2b" -Method POST -Body $Body

# Huzzah we can see a response!

