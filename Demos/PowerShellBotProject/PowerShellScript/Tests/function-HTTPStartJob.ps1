Describe "Start-PSRemoteJob.ps1 Tests" {

        # Define the URL Endpoint
        $URLEndpoint = "http://localhost:7071/api/HttpStartJob"

        <# 
        RESPONSE:
        {
            "Success" {
                "GUID":  "45f13471-9eea-4463-8b5d-96aa90e02de6",
                "Status":  "In Progress"
            }
        }
        #>

        Context "Testing Standard Request - Should not be null" {

            # Body of the Request
            $Body = @{
                ComputerName = "TEST01"
                Code = ""
            }

            # Invoke our initial Request Query
            $restResponse = Invoke-RestMethod -Uri $URLEndpoint -Method POST -ContentType "application/json" -Body $Body
            
            # Test the Response. Looking for Nulls
            it "Testing Initial Response - Looking for Errors" {
                $restResponse | Should not be $null
            }

            # Test the Response. Looking for Success.
            it "Testing the Response - Success Property" {
                $restResponse.Success | Should not be $null
            }

            # Test the Response. Looking for Error
            it "Testing the Response - Error Property" {
                $restResponse.Error | Should be $null
            }
            
            #
            # Test the Success Properties / (GUID / Status)
            
            # Testing GUID 
            it "Testing the Response - Success.GUID Property" {
                $restResponse.GUID | Should not be $null
            }
            # Testing Status
            it "Testing the Response - Success.Status Property" {
                $restResponse.Status | Should not be $null
            }

            # Test the Status Code Value
            it "Testing the Response - Success.Status Property -eq Queued" {
                $restResponse.Success.Status.ToLower() | Should be "queued"
            }

        }


}


