
@{

    #
    # Runbook Parameters
    #

    RunbookPSObject = @{
        # Runbook Name
        Name = "Set-ADRoleGroup"
        # Runboook Value
        Parameters = @(
            @{
                Name = "UserName"
                HTMLName = "INPUT_USERNAME"
            }
        ,
            @{
                Name = "ADRoleGroup"
                HTMLName = "SELECT_ROLEGROUP"
            }
        )
    }

    #
    # Rest Body Property
    #

    RestBody = @{
        Type = "AddUserToRoleGroup"
        HTMLNameSelected = "SELECT_ROLEGROUP"
    }

    #
    # Set the HTML Content
    #

    HTMLContent = @{
        Type = "AddUserToRoleGroup"
        ResponseURL = "https://pssummit.azure-api.net/InvokeRequest_HttpStart"
        Title = "Add a User to a Role Group"
        Description = "Creates a New User in the CatCorp Domain"
        Owners = @('email@address.com')
        HTMLConfig = @(         
            @{
                HTMLName = "INPUT_USERNAME"
                ElementType = "INPUT"
                Values = @("UserName")
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