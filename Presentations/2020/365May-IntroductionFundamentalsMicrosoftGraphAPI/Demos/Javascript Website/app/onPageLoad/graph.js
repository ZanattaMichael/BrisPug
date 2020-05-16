// Helper function to call MS Graph API endpoint 
// using authorization bearer token scheme
function callMSGraph(endpoint, accessToken, callback) {
    const headers = new Headers();
    const bearer = `Bearer ${accessToken}`;

    headers.append("Authorization", bearer);

    const options = {
        method: "GET",
        headers: headers
    };

    console.log('request made to Graph API at: ' + new Date().toString());

    fetch(endpoint, options)
        .then(response => response.json())
        .then(response => callback(response, endpoint))
        .catch(error => console.log(error));
}

//
// So how do we get a token and use it?
// Well it's this simple!
// Let's take a look at the method seeProfile()
// Note that it calls:
// getTokenPopup (See Below). This calls our MSAL object
// invoking the acquireTokenSilent() method.
// The token is returned and the rest request can be made
// 

async function seeProfile() {
    if (myMSALObj.getAccount()) {
        const response = await getTokenPopup(loginRequest).catch(error => {
            console.log(error);
        });
        callMSGraph(graphConfig.graphMeEndpoint, response.accessToken, updateUI);
        profileButton.style.display = 'none';
    }
}

/*
async function getTokenPopup(request) {
    return await myMSALObj.acquireTokenSilent(request).catch(async (error) => {
        console.log("silent token acquisition fails.");
        if (error instanceof msal.AuthenticationRequiredError) {
            if (msal.AuthenticationRequiredError.isInteractionRequiredError(error.errorCode, error.errorDesc)) {
                // fallback to interaction when silent call fails
                console.log("acquiring token using popup");
                return myMSALObj.acquireTokenPopup(request).catch(error => {
                    console.error(error);
                });
            }
        } else {
            console.error(error);
        }
    });
}
*/

async function readMail() {
    if (myMSALObj.getAccount()) {
        const response = await getTokenPopup(tokenRequest).catch(error => {
            console.log(error);
        });
        callMSGraph(graphConfig.graphMailEndpoint, response.accessToken, updateUI);
        mailButton.style.display = 'none';
    }
}
