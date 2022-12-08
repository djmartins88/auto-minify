// Initialise Apps framework client. See also:
// https://developer.zendesk.com/apps/docs/developer-guide/getting_started
var client = ZAFClient.init();

const APIURL = 'https://ciie7i6u2g.execute-api.us-east-1.amazonaws.com/organization/';

var mde = null;
var orgid = 'newidmock';

function getOrgId() {

    return new Promise(oid => {

        client.get('currentAccount').then(function(account_data) {

            let subdomain = account_data['currentAccount']['subdomain'];

            if (subdomain != undefined) {
                client.get('organization').then(function(organization_data) {
        
                    let zorgId = organization_data['organization']['id'];

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
        //dataType: 'application/json',
        httpCompleteResponse: 'true',
        //contentType: 'application/json',
    };
    //console.log(options);

    client.request(options).then(function(response) {

        if (response.status == 200 && response.responseJSON != null) {
            
            mde.value(response.responseJSON["md"]);
            resizeWidgetSize();

        } else {
            mde.value("It appears you haven't saved any notes for this Organization yet!");
        }
            
    }).catch(function(error) {

        // if service unavailable retry
        if (error.status == 503) {
            //console.log("retry load notes ..");
            loadNotes();
        } else {
            console.error(error);
            displayErrorAlert();
        }
    });

}

function saveNotes() {

    let markdown = mde.value();
    let html = mde.options.previewRender(markdown);

    let org = {"id": orgid, "md": markdown, "html": html};
    let json = JSON.stringify(org);

    let options = {
        url: APIURL + orgid,
        type:'PUT',
        contentType: 'application/json',
        data: json
    };
    // console.log(options);
    
    client.request(options).then(function(data) {
        // alert success
        displaySuccessAlert();

    }).catch(function(error) {
        
        // TODO catch and retry service unavailable
        if (error.status == 503) {
            //console.log("retry save notes ..");
            saveNotes();
        } else {
            console.error(error);
            displayErrorAlert();
        }
        

    })
}

function resizeWidgetSize() {
    let content = document.getElementById('content');
    client.invoke('resize', { width: '100%', height: content.offsetHeight + 30});

    //var d = Date(Date.now()).toString();
    //console.log(d + ': resize widget call');
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
        //console.log("modal ", data);
    });
}

function displaySuccessAlert() {
    return client.invoke('instances.create', {
      location: 'modal', 
      url: 'assets/modals/alert-success.html',
      size: { // optional
        width: '300px',
        height: '73px'
      }
    }).then(function(data) {
        //console.log("modal ", data);
    });
}

// initiliaze module after document is fully loaded
window.addEventListener('load',function(){

    // add editor - https://github.com/sparksuite/simplemde-markdown-editor
    mde = new SimpleMDE({ 
        element: document.getElementById("editor"),
        autofocus: true,
        indentWithTabs: false,
        renderingConfig: {
            singleLineBreaks: false,
            codeSyntaxHighlighting: false //requires aditional css and scripts
        },
        tabSize: 2,
        status: false
    });

    // load orgid (from ZD)
    async function getOrgIdAndLoadNotes() {
        orgid = await getOrgId();
        loadNotes();
        resizeWidgetSize();
    }

    getOrgIdAndLoadNotes();

    // set listener for buttons
    document.getElementById("savebtn").addEventListener("click", saveNotes, true);

});
