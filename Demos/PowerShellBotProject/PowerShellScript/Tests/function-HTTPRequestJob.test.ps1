Describe "HTTPRequestJob.ps1 Tests" {


        BeforeAll {

            # Load the Supporting Functions
            Get-ChildItem -LiteralPath "D:\Git\BrisPug\Demos\PowerShellBotProject\PowerShellScript\Tests\Supporting-Functions" -File | ForEach-Object{. $_.FullName}

            # Define the URL Endpoint
            $URLEndpoint = "http://localhost:7071/api/HttpRequestJob"
            
        }

        AfterAll {
            # TODO: CLEANUP
            #Invoke-SQLCleanup will deal with all the rows added to the table.

        }

        #
        # Now we are going to pretend to be the server. Fetch Request all the jobs from the server.

        Context "[Single Job] Testing Standard Request (url?query) - Should not be null" {

            #
            # ForEach Request. Refresh the REST Query:
            #

            BeforeAll {

                # Assuming that the Previous Test was Successfull we are going to Start a job to the server:

                # Define the Body of the Request
                $StartJobBody = @{
                    ComputerName = "PESTERTEST"
                    Code = ({Write-Output "PESTERTEST"}).ToString() | ConvertTo-Base64
                } | ConvertTo-Json

                # Invoke the Rest Method to Create a known good job. Once this is created, we can use this as our placeholder and source of truth.
                $null  = Invoke-RestMethod -Uri "http://localhost:7071/api/HttpStartJob" -Method POST -ContentType "application/json" -Body $StartJobBody        
                <# 
                RESPONSE:
                {
                    "Success" {
                        "GUID":  "45f13471-9eea-4463-8b5d-96aa90e02de6",
                        "Status":  "Queued"
                    }
                }
                #>

                $params = @{
                    Uri = "{0}?ComputerName={1}" -f $URLEndpoint, $StartJobBody.ComputerName    
                    ContentType  = "application/json"                
                }

                # Fetch the Server Jobs. Spat the Items in.
                $restResponse = Invoke-RestMethod @params
            }

            AfterAll {
                # TODO: CLEANUP
                #Invoke-SQLCleanup will deal with all the rows added to the table.
            }


            #
            # Tests
            #
            
            # Test the Response. Looking for Nulls
            it "Testing Initial Response - Looking for Errors" {
                $restResponse | Should not be $null
            }

            # Test the Response. Looking for Success.
            it "Testing the Response - Job Property" {
                $restResponse.Job | Should not be $null
            }

            # Test the Response. Looking for Error
            it "Testing the Response - Error Property" {
                $restResponse.Error | Should be $null
            }
            
            # Test the Response to Make Sure it's a Single Job
            it "Testing Single Job" {
                $restResponse.Job.Count | Should be 1
            }
            
            # Deseralize and Execute the PowerShell
            it "Testing Job Deserialization and Execution" {
                # Dot Source the Code
                (. { $restResponse.Job | ConvertFrom-Base64 }) | Should be "PESTERTEST"
            }

        }

       #
        # Now we are going to pretend to be the server. Fetch Request all the jobs from the server.

        Context "[Multi-Job] Testing Standard Request (url?query) - Should not be null" {

            #
            # ForEach Request. Refresh the REST Query:
            #

            #
            # ForEach Request. Refresh the REST Query:
            #

            BeforeAll {

                # Assuming that the Previous Test was Successfull we are going to Start a job to the server:

                # Define the Body of the Request
                $StartJobBody = @{
                    ComputerName = "PESTERTEST"
                    Code = ({Write-Output "PESTERTEST"}).ToString() | ConvertTo-Base64
                } | ConvertTo-Json

                # Create 4 Jobs.
                # Invoke the Rest Method to Create a known good job. Once this is created, we can use this as our placeholder and source of truth.
                $null = 0..3 | ForEach-Object { Invoke-RestMethod -Uri "http://localhost:7071/api/HttpStartJob" -Method POST -ContentType "application/json" -Body $StartJobBody }
                <# 
                RESPONSE:
                {
                    "Success" {
                        "GUID":  "45f13471-9eea-4463-8b5d-96aa90e02de6",
                        "Status":  "Queued"
                    }
                }
                #>

                $params = @{
                    Uri = "{0}?ComputerName={1}" -f $URLEndpoint, $StartJobBody.ComputerName    
                    ContentType  = "application/json"                
                }

                # Fetch the Server Jobs. Spat the Items in.
                $restResponse = Invoke-RestMethod @params
            }

            AfterAll {
                # TODO: CLEANUP
                #Invoke-SQLCleanup will deal with all the rows added to the table.
            }

            #
            # Tests
            #
            
            # Test the Response. Looking for Nulls
            it "Testing Initial Response - Looking for Errors" {
                $restResponse | Should not be $null
            }

            # Test the Response. Looking for Success.
            it "Testing the Response - Job Property" {
                $restResponse.Job | Should not be $null
            }

            # Test the Response. Looking for Error
            it "Testing the Response - Error Property" {
                $restResponse.Error | Should be $null
            }
            
            # Test the Response to Make Sure it's a Multiple Job
            it "Testing Single Job" {
                $restResponse.Job.Count | Should be 4
            }
            
            # Deseralize Each of the 4 Jobs and Execute Them
            0..3 | ForEach-Object {
                
                # Deseralize and Execute the PowerShell
                it "[JOB $($_)] Testing Job Deserialization and Execution" {
                    # Dot Source the Code
                    (. { $restResponse.Job[$_] | ConvertFrom-Base64 }) | Should be "PESTERTEST"
                }

            }



        }

        #
        # Testing for Error Handling
        #

        Context "Testing Standard Request - Sending Invalid Data" {

            # Body of the Request

            # Test the Response. Looking for Nulls
            it "Testing Missing Code Property - Looking for Error Property" {                
                # Set the Body (Missing the Jobs Property)
                $Body = @{
                   
                } | ConvertTo-Json
                # Invoke the Request Query
                $result = Invoke-TrapWebErrors { Invoke-RestMethod -Uri $URLEndpoint -Method POST -ContentType "application/json" -Body $Body }
                
                $obj = $result | ConvertFrom-Json
                $obj.Error | Should not be $null
            }
            
            # Test the Response. Looking for Nulls
            it "Testing Invalid Property (InvalidProperty) - Looking for Error Property" {                
                # Set the Body (Missing the Code Property)
                $Body = @{
                    InvalidProperty = "Testing"
                    Jobs = $RequestedJobs
                } | ConvertTo-Json
                # Invoke the Request Query
                $result = Invoke-TrapWebErrors { Invoke-RestMethod -Uri $URLEndpoint -Method POST -ContentType "application/json" -Body $Body }
                
                $obj = $result | ConvertFrom-Json
                $obj.Error | Should not be $null
            }            

        }

}


