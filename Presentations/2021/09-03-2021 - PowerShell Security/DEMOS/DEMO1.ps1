#
# Prework
#

Set-ExecutionPolicy -ExecutionPolicy Default

#
# Demo 1: Let's take the following demo:
#

Get-ExecutionPolicy

# Let's run the following script:
.\DEMO1.ps1

# Will Return
# Restricted

#
# Currently the execution policy is set to Restrictred
#

# So let's run:
Powershell.exe -ExecutionPolicy Bypass -File "C:\Users\Michael.Zanatta\OneDrive\MVP\TALKS\POWERSHELL MYTHBUSTERS\DEMOS\DemoScript.ps1"

#
# What the?
#

<#
# So what's happening here?

Let's take a look at the security policies:

a) All Signed. Any script that is signed with a code signing cert (local or internet) will prompt and run.
b) Bypass. Nothing is blocked. Used for applications to run code with internal security structure.
c) Default. Restricted for windows clients. RemoteSigned for windows servers.
d) RemoteSigned. Requires code signing certificate. Must be used in-conjunction with Unblock-File.
e) Restricted. Allow individual commands, but prevent all scripts from running.
d) Undefined. Falls back on Default.
e) UnRestricted. Runs all non signed scripts.

You can see that when we use the bypass policy that we are not blocking any activies and relying on the internal security strucuture.

This is a problem.

Can anyone bypass the security policy?

Short Answer?

No:

Let's take a look at the scope of the policy:

Scope: Scope define execution policy. Higher policies take precidence.
When we use powershell.exe -ExecutionPolicy, it will use the Process scope.

a) MachinePolicy (GPO)
b) UserPolicy (GPO)
c) Process. Affects the current PowerShell session. Defined at runtime. Stored in temp var $env:PSExecutionPolicyPreference
d) Current User. Affects the current user. Stored in HKCU registry.
e) LocalMachine. Affects the local machine. Stored in HKLM reg hive.

When you set executionpolicy, it's set at the lowest policy. Which means that the process policy, it overrights the user policy.
So how do this fix this?

Group Policy to the Rescue!

#>

#
# Demo 2: Setting Group Policy and Re-Running the Code
#

#Computer Configuration/ Windows Components/ Windows PowerShell / Turn On Script Execution
# GPUpdate

#
# Let's try again!

#open cmd.exe
Powershell.exe -ExecutionPolicy Bypass -File "C:\Users\Michael.Zanatta\OneDrive\MVP\TALKS\POWERSHELL MYTHBUSTERS\DEMOS\DemoScript.ps1"
Powershell.exe -ExecutionPolicy Get-ExecutionPolicy;pause