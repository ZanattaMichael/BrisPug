Describe "HTTPSendJob.ps1 Tests" {


        BeforeAll {

            # Load the Supporting Functions
            Get-ChildItem -LiteralPath "D:\Git\BrisPug\Demos\PowerShellBotProject\PowerShellScript\Tests\Supporting-Functions" -File | ForEach-Object{. $_.FullName}

            # Define the URL Endpoint
            $URLEndpoint = "http://localhost:7071/api/HttpSendJob"            
        }

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

            #
            # ForEach Request. Refresh the REST Query:
            #

            BeforeAll {
                # Define the Body of the Request
                $Body = @{
                    Success = $true
                } | ConvertTo-Json

                # Invoke our initial Request Query
                $restResponse = Invoke-RestMethod -Uri $URLEndpoint -Method POST -ContentType "application/json" -Body $Body -ErrorVariable errRest
            }

            #
            # Tests
            #
            
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
            # Test the Success Properties 423e1
            
            # Testing Success Property
            it "Testing the Response - RequestBody.GUID Property" {
                $restResponse.RequestBody.Success | Should be $true
            }   

        }

        #
        # Testing for Error Handling
        #

        Context "Testing Standard Request - Sending Invalid Data" {

            # Body of the Request

            # Test the Response. Looking for Nulls
            it "Testing Missing Code Property - Looking for Error Property" {                
                # Set the Body (Missing the Success Property)
                $Body = @{
                    
                } | ConvertTo-Json
                # Invoke the Request Query
                $result = Invoke-TrapWebErrors { Invoke-RestMethod -Uri $URLEndpoint -Method POST -ContentType "application/json" -Body $Body }
                
                $obj = $result | ConvertFrom-Json
                $obj.Error | Should not be $null
            }
            
            # Test the Response. Looking for Nulls
            it "Testing Invalid Property (InvalidProperty) - Looking for Error Property" {                
                # Set the Body (Additional Property)
                $Body = @{
                    InvalidProperty = "Testing"
                    Success = $true
                } | ConvertTo-Json
                # Invoke the Request Query
                $result = Invoke-TrapWebErrors { Invoke-RestMethod -Uri $URLEndpoint -Method POST -ContentType "application/json" -Body $Body }
                
                $obj = $result | ConvertFrom-Json
                $obj.Error | Should not be $null
            }            

        }

}


