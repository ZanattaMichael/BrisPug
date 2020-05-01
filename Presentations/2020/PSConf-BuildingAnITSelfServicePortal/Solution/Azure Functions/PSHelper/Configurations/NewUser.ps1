
@{

    #
    # Runbook Parameters
    #

    RunbookPSObject = @{
        # Runbook Name
        Name = "New-ADUser"
        # Runboook Value
        Parameters = @(
            @{
                Name = "firstname"
                HTMLName = "INPUT_FIRSTNAME"
            }
            ,
            @{
                Name = "lastname"
                HTMLName = "INPUT_LASTNAME"
            }
            ,
            @{
                Name = "RoleGroup"
                HTMLName = "SELECT_ROLEGROUP"
            }
        )
    }

    #
    # Rest Body Property
    #

    RestBody = @{
        Type = "NewUser"
        HTMLNameSelected = "INPUT_FIRSTNAME"
    }

    #
    # Set the HTML Content
    #

    HTMLContent = @{
        Type = "NewUser"
        ResponseURL = "https://pssummit.azure-api.net/InvokeRequest_HttpStart"
        Title = "Create a New User"
        Description = "Creates a New User in the CatCorp Domain"
        Owners = @('email@address.com')
        HTMLConfig = @(         
            @{
                HTMLName = "INPUT_FIRSTNAME"
                ElementType = "INPUT"
                Values = @("First Name")
            },
            @{
                HTMLName = "INPUT_LASTNAME"
                ElementType = "INPUT"
                Values = @("Last Name")
            },
            @{
                HTMLName = "SELECT_ROLEGROUP"
                ElementType = "SELECT"
                Values = @(
                    "Payroll_RoleGroup",
                    "AdminStaff_RoleGroup",
                    "Systems Engineer Role Group"
                    )
            }              
        )
    }

}