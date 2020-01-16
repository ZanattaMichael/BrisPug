
#
# DEMO: CREATING OBJECTS IN POWERSHELL - The Old Way
#

# This is the old PSv2 way of creating objects
$Object = New-Object -TypeName PSObject
# Let's Add Properties
$Object | Add-Member -MemberType NoteProperty -Name Name -Value "Reliant Robin"
$Object | Add-Member -MemberType NoteProperty -Name Description -Value "Used by comedians and rocket scientists alike, the Reliant Robin was a really terrible car."
$Object | Add-Member -MemberType NoteProperty -Name Wheels -Value "3"
$Object | Add-Member -MemberType NoteProperty -Name NumberOfWindows -Value "4"
$Object | Add-Member -MemberType NoteProperty -Name Engine -Value "Terrible"

# Get the Property

# Let's View the Object
$Object
# Let's View the Description
$Object.Description

## Add-Member is not recommended since it's slow. However if you are using one off's it's fine.

# Alternatives
# [PSCustomObject]@{ Name } for new items!
# Select-Object Expressions for existing!

#
# DEMO: CREATING OBJECTS IN POWERSHELL - The Preferred Way
#

# Here we are casting a hashtable as a PSObject or PSCustomObject
$Object = [PSCustomObject]@{
    Name = "Ford Falcon AU"
    Description = "Ford spent 600 million to build it and immediately it failed as plain ugly. It also blew head gaskets, radiators and thermostats, yet there are still a lot of AU taxis limping around."
    Wheels = 4
    NumberOfWindows = 6
    Engine = "Rubbish"
}

# Get the Property

# Let's View the Object
$Object
# Let's View the Description
$Object.Description

#
# DEMO: Accessing Objects Properties
#

# Here we are casting a hashtable as a PSObject or PSCustomObject
$Object = [PSCustomObject]@{
    # Note that I am creating a property with a space in it.
    # This is a big no-no, but is important.
    'Car Name' = "Ford Falcon AU"
    Description = "Ford spent 600 million to build it and immediately it failed as plain ugly. It also blew head gaskets, radiators and thermostats, yet there are still a lot of AU taxis limping around."
    Wheels = 4
    NumberOfWindows = 6
    Engine = "Rubbish"
}

# Get the Property

# Let's View the Object
$Object
# Let's View the Name by specifying the propertyname in a string.
# This allows us to overcome property with spaces in it.
$Object.'Car Name'

#
# DEMO: PowerShell Objects and Web
#

# Using ConvertTo-Json and ConvertFrom-Json we can
# Dynamically Seralize and Deseralize into a PSObject

# Let's use an example:
$Processes = Get-Process | Select-Object -First 1
# Let's view the type
$Processes.GetType()
# Let's Serialize into JSON
$JSON = $Processes | ConvertTo-Json
# Let's Print out the Data
$JSON
# Now Let's DeSearlize it into a PSObject
$PSObject = $JSON | ConvertFrom-Json
# Let's view the type
$PSObject.GetType()

#
# DEMO 06: Remove a Property
#

$Object = [PSCustomObject]@{
    Name = "Reliant Robin"
    Description = "Used by comedians and rocket scientists alike, the Reliant Robin was a really terrible car."
    Wheels = 3
    NumberOfWindows = 4
    Engine = "Terrible"
}

#
# A: Use Select Object

# There are two ways can be done:
# Implicit by Selecting the Properties that you want
$Object | Select-Object -Property Name, Description
# Or Explicitly. Note: When using the ExcludeProperty you explicitly remove them from the
# Object there. Note: You have to declare it in the -Property Parameter.
$Object | Select-Object -Property * -ExcludeProperty Wheels, NumberOfWindows, Engine
# So why would you want to do this?
# With Select Object you can use wildcards. For example:
# Let's fetch the object with all the properties that contain: *in*
$Object | Select-Object *in*
# You can see that NumberOfWindows and Engine was returned.
# Let's run the same statement, but now we can use wildcards on -ExcludeProperty
$Object | Select-Object *in* -ExcludeProperty *ine

#
# B: Using psobject.properties.remove() Method

# We can remove objects properties by using the psobject.properties.remove() method

$Object.psobject.Properties.Remove("Name")
# Let's print out Object Again
$Object
# Where is Name?

#
# DEMO: Object Variables
#

# Let's Create an Object
$Object = [PSCustomObject]@{
    Name = "Item"
}

# Let's 'Take a Copy' of the Object
$NewObject = $Object
# Let's update Name
$NewObject.Name = "NewName"
# Print out the Name
$NewObject.Name
# Looks Good Let's Print out the other object
$Object.Name
# Huh? It's been updated?

# Variables within an object will still hold a reference to the actual object.
# Even if you assign it to another object, it will still point to it.
# So what now? How do you make a copy?

# Let's use psobject.copy()
$NewObject = $Object.psobject.copy()
$NewObject.Name = "Somthing Else"

# Print out the New Name
$NewObject.Name
# Looks Good Let's Print out the other object
$Object.Name

#
# DEMO: Adding Properties
#

$UserGroup = [PSCustomObject]@{
    UserGroupName = "BrisPug"
}

#
# 1: SELECT-OBJECT (Expression)

# Select Expressions allow you to recreate an existing object, adding additional properties
# Select Expressions are denoted by the hashtable @{} with the Name, Expression 
$UserGroup = $UserGroup | Select-Object -Property *Name, @{Name = "UserGroupDescription"; Expression = {"Brisbane PowerShell User Group"}}

# Let's run it!
$UserGroup 

#
# 2: ADD-MEMBER

# You can also user Add-Member (But it is slow)

$UserGroup | Add-Member -MemberType NoteProperty -Name "Location" -Value "Hudson Technology"

# If you are piping Add-Member to somthing, make sure you use the -PassThru Paramter
# Since Add-Member doesn't return anything to the pipeline

#
# 3: USING PSOBJECT.PROPERTIES.ADD() METHOD:

# Let's add the "Presenter" Property
$UserGroup.psobject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Presenter', "Michael Zanatta"))
