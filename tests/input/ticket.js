// Initialise Apps framework client. See also:
// https://developer.zendesk.com/apps/docs/developer-guide/getting_started
var client = ZAFClient.init();

const APIURL = 'https://ciie7i6u2g.execute-api.us-east-1.amazonaws.com/organization/';

var orgid = 'newidmock';

function getOrgId() {

    return new Promise(oid => {

        client.get('currentAccount').then(function(account_data) {

            let subdomain = account_data['currentAccount']['subdomain'];
        
            if (subdomain != undefined) {
                client.get('ticket').then(function(ticket_data) {

                    let zorgId = ticket_data['ticket']['organization']['id'];

                    if (zorgId != undefined) {
                        orgid = subdomain + '@' + zorgId;
                    }

                    return orgid;
                })
                .then(function(orgId) {
                    oid(orgId); // resolve promise
                })
                .catch(function(error) {
                    console.error(error.toString());
                })

            } else {
                console.error("Unable to confirm your Zendesk Instance");
            }
        })
        .catch(function(error) {
            console.error(error.toString());
        })
    })

}

function loadNotes() {

    let options = {
        url: APIURL + orgid,
        type:'GET',
        httpCompleteResponse: 'true',
    };
    //console.log(options);

    client.request(options).then(function(response) {

        if (response.status == 200 && response.responseJSON != null) {
            
            var d = Date(Date.now()).toString();

            document.getElementById("content").innerHTML = response.responseJSON["html"];

            resizeWidgetSize();

        } else {
            document.getElementById("content").innerHTML = "It appears you haven't saved any notes for this Organization yet! You can add some on the Organization tab!";
        }
            
    }).catch(function(error) {

        // if service unavailable retry
        if (error.status == 503) {
            loadNotes();
        } else {
            console.error(error);
            displayErrorAlert();
        }
    });

}

function displayErrorAlert() {
    return client.invoke('instances.create', {
      location: 'modal', 
      url: 'assets/modals/alert-error.html',
      size: { // optional
        width: '300px',
        height: '73px'
      }
    }).then(function(data) {
        console.log("modal ", data);
    });
}

// function to resize widget size
function resizeWidgetSize() {
    let content = document.getElementById('content');
    client.invoke('resize', { width: '100%', height: content.offsetHeight});
}

// initiliaze module after document is fully loaded
window.addEventListener('load',function(){

    // load orgid (from ZD)
    async function getOrgIdAndLoadNotes() {
        orgid = await getOrgId();
        loadNotes();
        resizeWidgetSize();
    }

    getOrgIdAndLoadNotes();

});
