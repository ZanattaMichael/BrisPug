<#
# What is a PowerShell Object?
#

Let's take one step back and understand the basic definition of an object.
PowerShell is an object orientated language, which means it adhears to those standards.

An Object is physical grouping of Memory and Actions of similar values.
To create an Object, you need a class. A class is a blueprint to create the car.
Thinking about a car, you have the following common items:

1. Number of Wheels (Remeber the Reliant Robin)
2. Engine Type
3. Number of Doors
4. Number of Windows 
5. BodyType (Hach Back, Sedan, Wagon, Convertable)
6. Paint Colour
7. Number of Seats

These items would be called properties. Properties are gettable/settable variables.

Thankfully you dont need to worry about this.
All you need to remember is: "You group similar items with objects."

# So what is a PowerShell Object?

# It's a generic object that is used to group common values together.

# They come in multiple flavours:

[PSObject]
[PSCustomObject]

So what's the difference?

PSObject PowerShell Version 1 & 2
PSCustomObject PowerShell 3 and Up (Allows the Use of HashTables)

There are slight performance differences between the two:

[DEMO 01]
#>