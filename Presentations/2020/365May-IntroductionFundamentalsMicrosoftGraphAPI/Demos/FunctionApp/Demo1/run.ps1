using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$Body = @(
    @{
        Title = "Goodbye Moonman."
        CoverImage = $false
        Text = "
        The worlds can be one together
        Cosmos without hatred
        Stars like diamonds in your eyes
        The ground can be space
        (Space, space, space, space)
        With feet marching towards a peaceful sky
        All the Moonmen want things their way
        But we make sure they see the sun
        "
    },
    @{
        Title = "Ricks Astley. The Legend"
        CoverImage = $true
        Text = "
        Never gonna give you up
        Never gonna let you down
        Never gonna run around and desert you
        Never gonna make you cry
        Never gonna say goodbye
        Never gonna tell a lie and hurt you
        "
    },
    @{
        Title = "Cats. Humans most loved animal"
        CoverImage = $true
        Text = "
        1. Cats are the most popular pet in the United States: There are 88 million pet cats and 74 million dogs.

        2. There are cats who have survived falls from over 32 stories (320 meters) onto concrete.
        
        3. A group of cats is called a clowder.
        
        4. Cats have over 20 muscles that control their ears.
        
        5. Cats sleep 70% of their lives.
        
        6. A cat has been mayor of Talkeetna, Alaska, for 15 years. His name is Stubbs.
        
        7. And one ran for mayor of Mexico City in 2013.
        "
    }    
)

Wait-Debugger

Write-Host "Processed:"

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
