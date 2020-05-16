// Config object to be passed to Msal on creation
const msalConfig = {
    auth: {
        clientId: "3fba556e-5d4a-48e3-8e1a-fd57c12cb82e",
        authority: "https://login.windows-ppe.net/common/"
    },
    cache: {
        cacheLocation: "sessionStorage", // This configures where your cache will be stored
        storeAuthStateInCookie: false, // Set this to "true" if you are having issues on IE11 or Edge
    }
};  

// Add here scopes for id token to be used at MS Identity Platform endpoints.
const loginRequest = {
    scopes: ["User.Read"]
};

// Add here the endpoints for MS Graph API services you would like to use.
const graphConfig = {
    graphMeEndpoint: "https://graph.microsoft-ppe.com/v1.0/me",
    graphMailEndpoint: "https://graph.microsoft-ppe.com/v1.0/me/messages"
};

// Add here scopes for access token to be used at MS Graph API endpoints.
const tokenRequest = {
    scopes: ["Mail.Read"],
    forceRefresh: false // Set this to "true" to skip a cached token and go to the server to get a new token
};

const silentRequest = {
    scopes: ["3fba556e-5d4a-48e3-8e1a-fd57c12cb82e", "User.Read", "Mail.Read"]
};
