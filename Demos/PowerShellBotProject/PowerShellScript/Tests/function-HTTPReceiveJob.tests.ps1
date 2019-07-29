Describe "HttpRecieveJob.ps1 Tests" {


    BeforeAll {

        # Load the Supporting Functions
        Get-ChildItem -LiteralPath "D:\Git\BrisPug\Demos\PowerShellBotProject\PowerShellScript\Tests\Supporting-Functions" -File | ForEach-Object{. $_.FullName}

        # Cleanup SQL
        Invoke-SQLCleanup

        # Define the URL Endpoint
        $URLEndpoint = "http://localhost:7071/api/HttpRecieveJob"
        
    }

    AfterAll {
        # Cleanup the SQL Tables
        Invoke-SQLCleanup
    }

    #
    # Now we are going to pretend to be the server. Fetch Request all the jobs from the server.

    Context "Testing Standard Response - Testing for success property" {

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

            $RequestJobParams = @{
                Uri = "http://localhost:7071/api/HttpRequestJob?ComputerName={0}" -f $ComputerName
                ContentType  = "application/json"                
            }

            # Fetch the Server Jobs. Spat the Items in.
            $requestJobResponse = Invoke-RestMethod @RequestJobParams

            # Decode the Base64
            $plaintext = $requestJobResponse.Jobs.InputCliXML | ConvertFrom-Base64

            # Dot Source the Code
            $executionResponse = ([System.Management.Automation.ScriptBlock]::Create($plaintext).Invoke()) | ConvertTo-Base64
            
            # Define the Parameters to Send Back to Azure
            $params = @{
                Uri = "http://localhost:7071/api/HttpSendJob"
                Method = "POST"
                Body = @{
                    GUID = $requestJobResponse.Jobs.GUID
                    ResponseBody = $executionResponse
                    StatusCode = "Complete"
                } | ConvertTo-Json
                ContentType  = "application/json"
            }
            <#

            Expected Input:

                        {
                            "GUID" : "Value"
                            "ResponseBody" : "Value as B64"
                            "StatusCode" : "Response"
                        }
            
            Expected Response:
            
                        {
                            "success" : true
                        }

            #>
            # Send our Response Back to the Server
            $null = Invoke-RestMethod @params

            <#

            Expected Input:
            http://localhost:7071/api/HttpRecieveJob?GUID=GUID

            Success = @{
                GUID = $SQLResponse.GUID
                ComputerName = $SQLResponse.ComputerNameTarget
                Status = $SQLResponse.Status
            }
            #>

            $params = @{
                Uri = "{0}?GUID={1}" -f $URLEndpoint, $requestJobResponse.Jobs.GUID  
                ContentType  = "application/json"                
            }

            # Fetch the Server Jobs. Spat the Items in.
            $JobResponse = Invoke-RestMethod @params

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
            $JobResponse | Should not be $null
        }

        # Test the Response. Looking for Success Property.
        it "Testing the Response - Success Property" {
            $JobResponse.Success | Should not be $null
        }

        # Test the Response. Looking for Success Property.
        it "Testing the Response - Success.GUID Property" {
            $JobResponse.Success.GUID | Should not be $null
        }
 
        # Test the Response. Looking for Success Property.
        it "Testing the Response - Success.ComputerName Property" {
            $JobResponse.Success.ComputerName | Should not be $null
        }
        
        # Test the Response. Looking for Success Property.
        it "Testing the Response - Success.Status Property" {
            $JobResponse.Status | Should be "Completed"
        }   

        # Test the Response. Looking for Success Property.
        it "Testing the Response - Decode the Output Property and Validate it's Response" {
            # Decode the Response
            $DecodedOutput = $JobResponse.Output | ConvertFrom-Base64
            $DecodedOutput | Should be "PESTERTEST"
        }   
                      
    }

    #
    # Testing for Error Handling
    #
    
    Context "Testing Standard Response - Testing for failures" {

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

            $RequestJobParams = @{
                Uri = "http://localhost:7071/api/HttpRequestJob?ComputerName={0}" -f $ComputerName
                ContentType  = "application/json"                
            }

            # Fetch the Server Jobs. Spat the Items in.
            $requestJobResponse = Invoke-RestMethod @RequestJobParams

            # Decode the Base64
            $plaintext = $requestJobResponse.Jobs.InputCliXML | ConvertFrom-Base64

            # Dot Source the Code
            $executionResponse = ([System.Management.Automation.ScriptBlock]::Create($plaintext).Invoke()) | ConvertTo-Base64
            
            # Define the Parameters to Send Back to Azure
            $params = @{
                Uri = "http://localhost:7071/api/HttpSendJob"
                Method = "POST"
                Body = @{
                    GUID = $requestJobResponse.Jobs.GUID
                    ResponseBody = $executionResponse
                    StatusCode = "Complete"
                } | ConvertTo-Json
                ContentType  = "application/json"
            }
            <#

            Expected Input:

                        {
                            "GUID" : "Value"
                            "ResponseBody" : "Value as B64"
                            "StatusCode" : "Response"
                        }
            
            Expected Response:
            
                        {
                            "success" : true
                        }

            #>
            # Send our Response Back to the Server
            $null = Invoke-RestMethod @params

            <#

            Expected Input:
            http://localhost:7071/api/HttpRecieveJob?GUID=GUID

            Success = @{
                GUID = $SQLResponse.GUID
                ComputerName = $SQLResponse.ComputerNameTarget
                Status = $SQLResponse.Status
            }
            #>

            # Misspell the GUID Key
            $params = @{
                Uri = "{0}?GUIDD={1}" -f $URLEndpoint, $requestJobResponse.Jobs.GUID  
                ContentType  = "application/json"                
            }

            # Fetch the Server Jobs.
            $result = Invoke-TrapWebErrors { Invoke-RestMethod -Uri $params.Uri -ContentType $params.ContentType } | ConvertFrom-Json
        }

        # Test the Response. Looking for Nulls
        it "Testing Missing GUID Property - Looking for Error Property." {                
            $result | Should not be $null
        }
        
        # Testing Missing GUID Property. Testing for Success = $false
        it "Testing Missing GUID Property - Looking for Error Value." {                
            $result.Error | Should not be $null
        }               

    }

}


