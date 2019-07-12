Describe "HTTPRequestJob.ps1 Tests" {


        BeforeAll {

            # Load the Supporting Functions
            Get-ChildItem -LiteralPath "D:\Git\BrisPug\Demos\PowerShellBotProject\PowerShellScript\Tests\Supporting-Functions" -File | ForEach-Object{. $_.FullName}

            # Define the URL Endpoint
            $URLEndpoint = "http://localhost:7071/api/HttpRequestJob"
            
        }

        AfterAll {
            # Cleanup the SQL Tables
            Invoke-SQLCleanup
        }

        #
        # Now we are going to pretend to be the server. Fetch Request all the jobs from the server.

        Context "[Single Job] Testing Standard Request (url?query) - Should not be null" {

            #
            # ForEach Request. Refresh the REST Query:
            #

            BeforeAll {

                # Assuming that the Previous Test was Successfull we are going to Start a job to the server:

                # Define the "Test ComputerName"
                $ComputerName = "PESTERTEST"
                # Define the Body of the Request\                
                $StartJobBody = @{
                    ComputerName = $ComputerName
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
                    Uri = "{0}?ComputerName={1}" -f $URLEndpoint, $ComputerName  
                    ContentType  = "application/json"                
                }

                # Fetch the Server Jobs. Spat the Items in.
                $restResponse = Invoke-RestMethod @params
            }

            AfterAll {
                # Cleanup the SQL Tables
                Invoke-SQLCleanup
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
                $restResponse.Jobs | Should not be $null
            }

            # Test the Response. Looking for Error
            it "Testing the Response - Error Property" {
                $restResponse.Error | Should be $null
            }
            
            # Test the Response to Make Sure it's a Single Job
            it "Testing Single Job" {
                $restResponse.Jobs.Count | Should be 1
            }
            
            # Decode and Execute the PowerShell
            it "Testing Job Decoding and Execution" {

                # Decode the Base64
                $paintext = $restResponse.Jobs.InputCliXML | ConvertFrom-Base64

                # Dot Source the Code
                ([System.Management.Automation.ScriptBlock]::Create($paintext).Invoke()) | Should be "PESTERTEST"
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

                # Define the "Test ComputerName"
                $ComputerName = "PESTERTEST"
                # Define the Body of the Request\                
                $StartJobBody = @{
                    ComputerName = $ComputerName
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
                    Uri = "{0}?ComputerName={1}" -f $URLEndpoint, $ComputerName  
                    ContentType  = "application/json"                
                }

                # Fetch the Server Jobs. Spat the Items in.
                $restResponse = Invoke-RestMethod @params
            }

            AfterAll {
                # Cleanup the SQL Tables
                Invoke-SQLCleanup
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
                $restResponse.Jobs | Should not be $null
            }

            # Test the Response. Looking for Error
            it "Testing the Response - Error Property" {
                $restResponse.Error | Should be $null
            }
            
            # Test the Response to Make Sure it's a Multiple Job
            it "Testing Single Job" {
                $restResponse.Jobs.Count | Should be 4
            }
            
            # Deseralize Each of the 4 Jobs and Execute Them
            0..3 | ForEach-Object {
                
                # Deseralize and Execute the PowerShell
                it "[JOB $($_)] Testing Job Deserialization and Execution" {

                    # Decode the Base64
                    $paintext = $restResponse.Jobs[$_].InputCliXML | ConvertFrom-Base64

                    # Dot Source the Code
                    ([System.Management.Automation.ScriptBlock]::Create($paintext).Invoke()) | Should be "PESTERTEST"

                }

            }

        }

        #
        # Testing for Error Handling
        #
        
        Context "Testing Standard Request - Sending Invalid Data" {

            AfterAll {
                # Cleanup the SQL Tables
                Invoke-SQLCleanup
            }

            # Test the Response. Looking for Nulls
            it "Testing Missing Code Property - Looking for Error Property" {                

                # Define the Parameters
                $Uri = "{0}?=INVALIDKEY{1}" -f $URLEndpoint, $ComputerName  

                # Invoke the Request Query
                $result = Invoke-TrapWebErrors { Invoke-RestMethod -Uri $Uri -ContentType "application/json" }
                
                $obj = $result | ConvertFrom-Json
                $obj.Error | Should not be $null

            }
            
            # Test the Response. With an Empty String
            it "Testing Missing ComputerName Value - Looking for Error Property" {                

                # Define the Parameters
                $Uri = "{0}?COMPUTERNAME=" -f $URLEndpoint  

                # Invoke the Request Query
                $result = Invoke-TrapWebErrors { Invoke-RestMethod -Uri $Uri -ContentType "application/json" }
                
                $obj = $result | ConvertFrom-Json
                $obj.Error | Should not be $null

            }          

        }

}


