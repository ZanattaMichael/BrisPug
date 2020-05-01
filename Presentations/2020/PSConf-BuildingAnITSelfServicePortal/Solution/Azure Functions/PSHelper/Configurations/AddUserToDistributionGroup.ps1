
@{

    #
    # Runbook Parameters
    #

    RunbookPSObject = @{
        # Runbook Name
        Name = "AddUserToDistributionGroup"
        # Runboook Value
        Parameters = @(
            @{
                Name = "UserName"
                HTMLName = "INPUT_USERNAME"
            },
            @{
                Name = "DistributionGroup"
                HTMLName = "SELECT_DISTROGROUP"
            }            
        )
    }

    #
    # Rest Body Property
    #

    RestBody = @{
        Type = "AddUserToDistributionGroup"
        HTMLNameSelected = "SELECT_DISTROGROUP"
    }

    #
    # Set the HTML Content
    #

    HTMLContent = @{
        Type = "AddUserToDistributionGroup"
        ResponseURL = "The URL to sent the REST response to."
        Title = "Add a User to a Distribution Group"
        Description = "Add a User to the Listed Distribution Group!"
        Owners = @('email@address.com')

        HTMLConfig = @(         
            @{
                HTMLName = "INPUT_USERNAME"
                ElementType = "INPUT"
                Values = @("Username")
            },
            @{
                HTMLName = "SELECT_DISTROGROUP"
                ElementType = "SELECT"
                Values = @(
                    "All Staff Distribution Group",
                    "Finance Distribution Group",
                    "IT Distribution Group"
                )
            }                     
        )
    }

}