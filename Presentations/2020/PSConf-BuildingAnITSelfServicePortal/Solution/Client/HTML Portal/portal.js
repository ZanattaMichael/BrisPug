
// Create a storage location for the Data from the Initialization
var myAPIData = null;

//
// Submit a Self Service Request
//

//
// Submit a Request to the API Endpoint
// This function dynamically builds the REST response
// needed to send a request the API endpoint.
//

function submitRequest(TileIndexValue) {

    // Load the htmlObject
    htmlObject = window.myAPIData[TileIndexValue];

    // Construct the Rest Body Response
    body = {
        Type : htmlObject.httpContent.Type,
        HTMLNameSelected : htmlObject.RestBody.HTMLNameSelected,
        HTTPResponseBodyParameters : []
    };

    // Now that we have an initial body loaded, we must index
    // through each of the runbook parameters and perform lookups
    // on the HTMLName. The HTMLName is used as a reference
    // for all elements within the configuration.
    // Once joined, we can then use that information to get the element value.


    //
    // Iterate Through the Response Parameters and add to the body
    for (parameter in htmlObject.AzureAutomationRunbook.Parameters) {

        // Get the Object
        parameterItem = htmlObject.AzureAutomationRunbook.Parameters[parameter]

        // Perform a Lookup and Get the HTMLConfig Value
        htmlConfig = getHTMLConfig(htmlObject, parameterItem.HTMLName);

        // Remove request
        if(htmlConfig === null)
            return 
    
        // Construct the Element ID
        elementID = `TILE_${htmlObject.httpContent.Type}_${htmlConfig.HTMLName}`;

        try {
            e = document.getElementById(elementID);
        } catch (err) {
            console.log(err);
            return;
        }

        switch(htmlConfig.ElementType) {
            case "SELECT":
                value = e.options[e.selectedIndex].value;
                break;
            case "INPUT":
                value = e.value
                break;
            default:
                console.log("Unable to get ElementType from configuration. Stopping.");
                return;
        }

        // Add the Parameter name and value to the body of the request.
        body.HTTPResponseBodyParameters.push({
            Name : parameterItem.Name,
            Value : value
        });
    };

    // Send the Request
    AquireTokenAndInvokeRestMethod(
        htmlObject.httpContent.ResponseURL,
        "POST",
        null,
        body
    )

    // Submit a Request
    M.toast({
        html: 'Request Submitted',
        classes: 'indigo darken-4 white-text'
    });

}

//
// Tile Rendering Functions
//

function RenderConfiguration(configurationItems) {

    // Get the Placeholder
    TileContent = document.getElementById("TilePlaceholder");
    // Clear the Existing Configuration within the DOM
    removeTile(TileContent);

    // Iterate through Each of the Config items
    for (configurationItem in configurationItems) {

        httpContent = configurationItems[configurationItem].httpContent;
        tileId = `TILE_${configurationItems[configurationItem].httpContent.Type}`;
        tileIndex = configurationItem;
        
        try {
            newTile(httpContent, TileContent, tileId, tileIndex);
        } catch (error) {
            console.log("There was a problem rending the configuration item:");
            console.log(error);
        }

    }

    // Hide the Loader Bar:
    hideLoader();
}

function removeTile(tileContent) {
    // Flush the Tile Content and Recreate it
    while (tileContent.hasChildNodes()) {
        tileContent.removeChild(tileContent.lastChild);
    }
}

function newTile(httpContent, tileContent, tileId, tileIndex) {

    tile = document.createElement("div")
    tile.setAttribute('id', tileId);
    tile.setAttribute('class', 'card blue-grey darken-1 col s5 container-margin');
    tileContent.appendChild(tile);

    // Create the Body of the Element
    tileBody = document.createElement("div");
    tileBody.setAttribute('class','card-content white-text section');
    tileBody.setAttribute('id',`${tileId}_body`);
    tile.appendChild(tileBody);

    //tile.appendChild(tileBody);

    // Create the Action Element of the Tile
    tileAction = document.createElement("div");
    tileAction.setAttribute('class','card-action');
    tileAction.setAttribute('id',`${tileId}_action`);
    tile.appendChild(tileAction);

    //
    // Create the Body of the Tile


    body = document.createElement("div");
    bodyTitle = document.createElement("span");
    bodyOwners = document.createElement("ul");
    bodyText = document.createElement("p");
    form = document.createElement("div");
    divider = document.createElement("div");

    formId = `${tileId}_form`

    form.setAttribute('id', formId);
    form.setAttribute('class', 'section');
    bodyTitle.setAttribute('class','card-title');
    bodyOwners.innerHTML = "Owners:"
    bodyOwners.setAttribute('type','disc');
    divider.setAttribute('class','divider');

    // Set the Data for the Body    
    bodyTitle.innerHTML = `${httpContent.Title}`;
    bodyText.innerHTML = `Description: ${httpContent.Description}`;

    for (owner in httpContent.Owners) { 
        var li = document.createElement("li");
        li.innerHTML = `${httpContent.Owners[owner]}`;
        bodyOwners.appendChild(li);
    }
    
    // Build the Form Data
    for (htmlConfig in httpContent.HTMLConfigs) {

        var htmlConfigItem = httpContent.HTMLConfigs[htmlConfig];

        formElement = document.createElement(htmlConfigItem.ElementType);
        formElement.setAttribute('id', `${tileId}_${htmlConfigItem.HTMLName}`);
        formElement.setAttribute('class', 'browser-default');
        form.appendChild(formElement);

        switch(htmlConfigItem.ElementType) {
            case 'SELECT':
                for (option in htmlConfigItem.Values) {
                    val = htmlConfigItem.Values[option];
                    opt = document.createElement("option");
                    opt.setAttribute('value', val);
                    opt.innerHTML = val;
                    formElement.appendChild(opt);
                }
                break;

            case 'INPUT':
                formElement.setAttribute('class', 'white-text')
                formElement.setAttribute('placeholder', htmlConfigItem.Values)
                break;

            default:
        }
    }

    // Append the child
    body.appendChild(bodyTitle);
    body.appendChild(bodyText);
    body.appendChild(bodyOwners);
    body.appendChild(divider);

    tileBody.appendChild(body);
    tileBody.appendChild(form);

    // Submit Icon
    icon = document.createElement('i');
    icon.setAttribute('class', 'material-icons right');
    icon.innerHTML = 'send';

    // Build the Submit Button
    submit = document.createElement('button');
    submit.setAttribute('class','btn waves-effect waves-light');
    submit.setAttribute('type', 'submit');
    submit.setAttribute('name', 'action');
    submit.setAttribute('onclick', `submitRequest(${tileIndex})`);
    submit.appendChild(icon);
    
    tileAction.appendChild(submit);
    submit.innerHTML = 'Submit Request';
    

}

//
// Show the Load Screen
function showLoader() {
    var x = document.getElementById("loader");
    x.style.display = "block";
}

//
// Hide the Load Screen
function hideLoader() {
    var x = document.getElementById("loader");
    x.style.display = "none";
}

//
// getHTMLConfig perform a LINQ based search to find
// htmlObjects within the configuration with the requested HTMLName.
function getHTMLConfig(htmlObject, HTMLName){
    
    try {
        // Fetch a list of htmlObject that contain the tile index value
        httpConfig = htmlObject.httpContent.HTMLConfigs.filter(function (item) {
            return item.HTMLName === HTMLName;
        });
        // Test Collection Length
        
        if(httpConfig.length > 1)
            throw `[getHTMLConfig] Cannot HTMLName ${HTMLName} in htmlObject`;
        
        return httpConfig.length === 0 ? null : httpConfig[0];
        
    } catch (err) {
        console.log(err)
    }

}