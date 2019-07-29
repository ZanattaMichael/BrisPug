Describe "PowerShell Fun" {

    function ConvertTo-Base64 {
        <#
        
        .SYNOPSIS
        Converts a string to a Base64 String
        
        .DESCRIPTION
        Converts a string to a Base64 String
        
        .EXAMPLE
        "asdadasdasdasd" | ConvertTo-Base64
        
        .NOTES
        Example Output:
        
        (BASE64 String)YQBzAGQAYQBkAGEAcwBkAGEAcwBkAGEAcwBkAA==
                                                                                                                                   
        .LINK
        https://au.linkedin.com/in/michael-zanatta-61670258
        
        #>
            [CmdletBinding()]
            Param (
            
                [parameter(
                    ValueFromPipeline=$True,
                    Mandatory=$true
                )]
                [String]$String
        
            )
        
            # 
            # This function converts a string into BASE64
            #
            begin {
        
         
                #
                # region Initalize code
                #
                Write-Verbose "[CMDLET] ConvertTo-Base64"
                Write-Verbose "{BEGIN} START"
                
                #
                # endregion Initalize code
                #       
        
            } 
        
            process {
                
                #
                # region Process code
                #
                Write-Verbose "{PROCESS} START"
                Write-Verbose "Converting String to BASE64. DUMP:"
                Write-Verbose "$String"
        
                $obj = [System.Convert]::ToBase64String(([System.Text.Encoding]::UTF8.GetBytes($String)))
        
                Write-Verbose "Converted to:"
                Write-Verbose $obj
                
                #
                # endregion Process code
                #
        
            }
        
            end {
        
                #
                # region Cleanup code
                #
                Write-Verbose "{END} START"
        
                return $obj
        
                #
                # endregion Cleanup code
                #
        
        
            }
        
    }

    function ConvertFrom-Base64 {
        <#
        
        .SYNOPSIS
        Converts a Base64 string to a normal String
        
        .DESCRIPTION
        Converts a Base64 string to a normal String
        
        .EXAMPLE
        "YQBzAGQAYQBkAGEAcwBkAGEAcwBkAGEAcwBkAA==" | ConvertTo-Base64
        
        .NOTES
        Example Output:
        
        (BASE64 String)asdadasdasdasd
                                                                                                                                    
        .LINK
        https://au.linkedin.com/in/michael-zanatta-61670258
        
        #>
        
            [CmdletBinding()]
            Param (
            
                [parameter(
                    ValueFromPipeline=$True,
                    Mandatory=$true
                )]
                [String]$EncodedText
        
            )
        
            # 
            # This function converts a string into JSON from BASE64
            #
            begin {
        
                #
                # region Initalize code
                #
                Write-Verbose "[CMDLET] ConvertFrom-Base64"
                Write-Verbose "{BEGIN} START"
                
                #
                # endregion Initalize code
                #       
                
        
            } 
        
            process {
        
                #
                # region Process code
                #
                Write-Verbose "{PROCESS} START"
                Write-Verbose "Converting BASE64 to String. DUMP:"
                Write-Verbose "$EncodedText"
        
                # Set the Success to be False
                $Success = $false
                # Set a Counter
                $count = 1
        
                do {
        
                    try {
                        # Try Convert The Object
                        $obj = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncodedText))
                        # Set Success Flag
                        $Success = $True
                        # Break
                        break
                    } catch {
                        # Add some padding and try again
                        $EncodedText = "$EncodedText="
                        $CaughtError = $_
                    }
        
                } Until ($count++ -gt 2)
        
                # If the result failed, then throw a terminating error
                if (-not($Success)) {
                    throw $CaughtError
                }
        
                Write-Verbose "Converted to:"
                Write-Verbose $obj
                
                #
                # endregion Process code
                #
        
            }
        
            end {
        
                #
                # region Cleanup code
                #
                Write-Verbose "{END} START"
        
                return $obj
        
                #
                # endregion Cleanup code
                #
        
            }
        
    }    

    Context "Testing: Object Types" {
        #
        #
        #
        # DO NOT SCROLL
        #
        #
        #

        it "Testing: Object Types - What Type is: `"VALUE`"?" {
            #
            # Act 
            $var = "String"

            #
            # Action

            #
            # Assert            
            $var | ConvertTo-Base64 | Should be "U3RyaW5n"

        }

        #
        #
        #
        # DO NOT SCROLL
        #
        #
        #

        it "Testing: Object Types - What Type is: 1?" {
            #
            # Act 
            $var = "Integer"

            #
            # Action

            #
            # Assert            
            $var | ConvertTo-Base64 | Should be "SW50ZWdlcg=="

        }

        #
        #
        #
        # DO NOT SCROLL
        #
        #
        #

        it "Testing: Object Types - What cmdlet do you use to get the Object Type?" {
            #
            # Act 
            $var = "Get-Member"

            #
            # Action

            #
            # Assert            
            $var | ConvertTo-Base64 | Should be "R2V0LU1lbWJlcg=="

        }        

    }

    
    Context "Testing PowerShell - Object Creation - HastTables" {

        #
        #
        #
        # DO NOT SCROLL
        #
        #
        #

        it "Testing: HashTables - How do you create a hashtable?" {
            #
            # Act            
            $var = @{
                Var1 = "Blah"
                Var2 = "Meh"
            }

            #
            # Action

            #
            # Assert
            $var -is [HashTable] | Should be $true
        }

        #
        #
        #
        # DO NOT SCROLL
        #
        #
        #

        it "Testing: HashTables - How do you add LastName to a HashTable?" {
            #
            # Act

            $var = @{ FirstName = "Michael"}

            #
            # Action

            # DO SOMTHING SOMTHING HERE
            $var.Add("LastName", "Zanatta")
            
            #
            # Assert
            $var -is [HashTable] | Should be $true
            $var.LastName | Should be $true
        }

        #
        #
        #
        # DO NOT SCROLL
        #
        #
        #

        it "Testing: HashTables - How do I remove LastName from a HashTable?" {


            #
            # Act            
            $var = @{ FirstName = "Michael" ; LastName = "Zanatta"}

            #
            # Action

            # DO SOMTHING SOMTHING HERE
            $var.Remove("LastName")

            #
            # Assert
            #region hidden
            $var -is [HashTable] | Should be $true
            $var.LastName | Should be $null
            #endregion hidden
        }

    }

    #
    #
    #
    # DO NOT SCROLL
    #
    #
    #

    Context "Testing PowerShell - Pipeline Use" {

        #
        #
        #
        # DO NOT SCROLL
        #
        #
        #

        it "Exercise: Pipeline - In `$Var, Return a list of all the Windows Processes that contains the name 'svchost'." {

            #
            # Act            
            $var = Get-Process | Where-Object -Property ProcessName -like "*svchost*"

            #
            # Action

            # DO SOMTHING SOMTHING HERE
            
            #
            # Assert

            #region hidden
            $var.where{$_.Name -ne "svchost"} | Should be $null
            #endregion hidden

        }

        #
        #
        #
        # DO NOT SCROLL
        #
        #
        #

        it "Exercise: Pipeline - In `$Var, Return a Windows Processes that contains the name 'svchost'. Return only 10" {

            #
            # Act            
            $var = Get-Process | Where-Object -Property ProcessName -like "*svchost*" | Select-Object -First 10
            #
            # Action
            
            #
            # Assert

            #region hidden
            $var.where{$_.Name -ne "svchost"} | Should be $null
            $var | Measure-Object | Select-Object -ExpandProperty Count | Should be 10
            #endregion hidden

        }        

    }

}