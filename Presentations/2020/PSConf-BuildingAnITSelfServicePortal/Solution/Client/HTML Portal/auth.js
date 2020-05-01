// Config object to be passed to Msal on creation
var msalConfig = {
    auth: {
        clientId: 'CLIENT ID' //This is your client ID
    },
    cache: {
        cacheLocation: "localStorage",
        storeAuthStateInCookie: true
    }
};

// Function Endpoint for Initialization
const apimConfig = {
    functionEndpoint: "https://pssummit.azure-api.net/Initialize",
    functionMethod: "GET"
};

// Define the Scopes to call
const requestObj = {
    scopes: ["api://AutomationTaskClient/App.Read"]
};

// Create the main myMSALObj instance
var myMSALObj;

//
// Events
//

$(document).ready(function () {

    // Create a new Object
    window.myMSALObj = new Msal.UserAgentApplication(msalConfig);
    // Register Callbacks for redirect flow
    myMSALObj.handleRedirectCallback(authRedirectCallBack);

    async function acquireTokenAndInitialize(response) {
        let Token;
        try {
            // Fetch a Token and Call Invoke Rest Method
            AquireTokenAndInvokeRestMethod(
                apimConfig.functionEndpoint,
                apimConfig.functionMethod,
                AzureFunctionInitializeCallback
            );
        } catch (error) {
            console.log(error);
        }
        console.log(Token);
    }

    function authRedirectCallBack(error, response) {
        if (error) {
            console.log(error);
        } else {
            console.log("ERE");
            if (response.tokenType === "access_token") {
                acquireTokenAndInitialize(response);
            } else {
                console.log("token type is: %s", 0);
            }
        }
    }

    myMSALObj.loginPopup(requestObj).then(response => {
        console.log("Successpopup");
        console.log(response);
        //Login Success callback code here
        acquireTokenAndInitialize(response);
    }).catch(error => {
        console.log(error);
    });
    
    //
    // Callback Functions
    //

    //
    // Pull the Configuration
    function AzureFunctionInitializeCallback(data) {
        // Set the Configuration
        myAPIData = data;
        // Call the RenderConfiguration
        RenderConfiguration(myAPIData);
    }

    //
    // Create a value for Requests Submitted
    function RequestFunctionResponse(data) {
        console.log(data.responseText);
    }

}());




