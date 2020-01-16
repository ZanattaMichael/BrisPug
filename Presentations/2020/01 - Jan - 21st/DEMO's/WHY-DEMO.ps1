
#
# DEMO: Having a custom object makes your code easier to read. For Example: Take a look at the Pusdo PowerShell Code
#

#
# Initial

$DoSomthing = 1,2,3,4,5,6,7,8
For ($Somthing in $DoSomthing) {

    $UserName = Get-UserName -UserName $Somthing
    $Description = Get-Description -UserName $Somthing
    $GetInfo = Get-Item -LiteralPath ("C:\Windows\$Somthing.exe")

    # Now we are going to do some actions with those variables
    $RandomResult = Start-RandomFunction -UserName $UserName -Description $Description -GetInfo $GetInfo
    # Append RandomResult in Description
    $Description = "$Description $RandomResult"
    
    # We are going to call those variables again here and do somthing else.   
    Write-Output $UserName, $Description, $GetInfo, $RandomResult
}

#
# Refactored

# Now there was nothing wrong with that, however we can make it easier to read:

$DoSomthing = 1,2,3,4,5,6,7,8
For ($Somthing in $DoSomthing) {

    $UserInfomation = [PSCustomObject]@{
        UserName = Get-UserName -UserName $Somthing
        Description = Get-Description -UserName $Somthing
        GetInfo = Get-Item -LiteralPath ("C:\Windows\$Somthing.exe")
        RandomResult = $null
    }

    # Now we are going to do some actions with those variables
    $UserInfomation.RandomResult = Start-RandomFunction -UserName $UserName `
            -Description $Description `
            -GetInfo $GetInfo

    # Let's ammend the property
    $UserInfomation.Description = "{0}{1}" -f $UserInfomation.Description, $UserInfomation.RandomResult

    # Now we can refactor this previous line further, but for this demo we won't

    # Let's return the object 
    Write-Output $UserInfomation
}
# In the second code block we are grouping are items together. It makes it MUCH easier to manage and to understand.

#
# DEMO: We can use PSObject to glue our two different objects.
# In this scenario, you are querying an AD User and joining the data with an Exchange Object
#

# These are mock functions Emulating Get-ADUser and Get-Mailbox
# Ignore this function
Function Get-ADUser($Identity) {

    class ADUser {
        $Identity = "Test.User1"
        $SamAccountName = "Test.User1"
        $DistunguishedName = "CN=Test User 1,OU=Users,DN=Contoso,DN=local"
        $Enabled = $true
        $UserPrincialName = "Test.User1@contoso.local"

        ADUser() {}
    }

    return [ADUser]::New()

}

Function Get-Mailbox($Identity) {

    class ExchangeMailbox {
        $Identity = "Test.User1"
        $SamAccountName = "Test.User1"
        $DistunguishedName = "CN=Test User 1,OU=Users,DN=Contoso,DN=local"
        $Enabled = $true
        $UserPrincialName = "Test.User1@contoso.local"
        $MailboxAddresses = @("SMTP:Test.User1@contoso.local","smtp:Test.User2@contoso.local")
        $isMailEnabled = $true
        $PrimarySMTPAddress = "Test.User1@contoso.local"
        $AutoReply = $false

        ExchangeMailbox() {}
    }

    return [ExchangeMailbox]::New()

}

#
# We can glue them together in their respective object types

$UserObject = [PSCustomObject]@{
    ADUser = Get-ADUser -Identity "Test.User1"
    Mailbox = Get-Mailbox -Identity "Test.User1"
}
# Let's print out $UserObject
$UserObject
# You can see that the UserObject contains both items
# Let's take a look at them
$UserObject.ADUser
$UserObject.Mailbox

# We have glued them together with an Object.
# There is also another way to do this. That is to use Select Expressions.

