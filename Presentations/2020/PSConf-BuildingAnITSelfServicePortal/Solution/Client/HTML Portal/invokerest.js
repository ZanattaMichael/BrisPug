

async function AquireTokenAndInvokeRestMethod(Url, Method, callbackMethod, Body) {

    // if the user is already logged in you can acquire a token
    if (myMSALObj.getAccount()) {

        var response = myMSALObj.acquireTokenSilent(requestObj)
        .then(response => {
            // get access token from response
            // response.accessToken
            InvokeRestMethod(Url, Method, callbackMethod, Body, response);
            console.log(response.accessToken);
        })
        .catch(err => {
            // could also check if err instance of InteractionRequiredAuthError if you can import the class.
            if (err.name === "InteractionRequiredAuthError") {
                return myMSALObj.acquireTokenPopup(requestObj)
                    .then(response => {
                            InvokeRestMethod(Url, Method, callbackMethod, Body, response);
                            console.log(response.accessToken);
                    })
                    .catch(err => {
                        // handle error
                        console.log(err);
                        throw err;
                    });
            }
        });
    } else {
        // User is not logged in, you will need to log them in to acquire a token
        console.log("User is not logged in. Please refresh the page");
    }
}

//
// System Functions
//

async function InvokeRestMethod(Url, Method, callbackMethod, Body, tokenResponse) {
    const xmlHttp = new XMLHttpRequest();

    if (callbackMethod)
        xmlHttp.onreadystatechange = function () {
            if (this.readyState === 4 && this.status === 200)
                callbackMethod(JSON.parse(this.responseText));
        };

    // Create the Session
    xmlHttp.open(Method, Url, true); // true for asynchronous

    // Set the Access Token
    xmlHttp.setRequestHeader("Authorization", `Bearer ${tokenResponse.accessToken}`);   

    // Add the body was included
    if (Body) {
        xmlHttp.setRequestHeader("Content-Type", "application/json");
        xmlHttp.send(JSON.stringify(Body));
    } else {
        // Send the Request
        xmlHttp.send();
    }
}
