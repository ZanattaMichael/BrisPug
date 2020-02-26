
#
# Load the CSV File
$CSVFile = Import-CSV -Path "D:\Git\BrisPug\Presentations\2020\02 - Mar - 3rd\SUPPORTING SCRIPTS\USERS.csv"

#
# Get the First 10 Users
$First10Users = $CSVFile | Select-Object -First 10

#
# Let's iterate through each of those users.
# We can do this by using a ForEach loop.
ForEach($User in $First10Users) {

    # Let's Create a basic Active Directory User using the Information Provided
    # From the CSV File
    New-ADUser -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -Name $User.Name

}

