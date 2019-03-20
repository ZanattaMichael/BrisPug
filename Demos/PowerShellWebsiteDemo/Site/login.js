
var url = "CHANGE THIS"

function Login() {
    // Define the Object
    var obj = {
        username : document.getElementById('loginUsername').value,
        password : document.getElementById('loginPassword').value,
        mfapin : document.getElementById('loginMFAPIN').value
    }
    // Parse as Json
    var json = JSON.stringify(obj);

    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {

        // Define the Response
        if (this.readyState == 4 && this.status == 200) {

            alert(this.responseText);

        }
    
    }
    xhttp.open("POST", url, true);
    xhttp.setRequestHeader("Content-type", "application/json");
    xhttp.send(json);

}