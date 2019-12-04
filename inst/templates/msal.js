// The current application coordinates were pre-registered in a B2C tenant.
var appConfig = {
    b2cScopes: [ #SCOPES# ]
};


// configuration to initialize msal
const msalConfig = {
    auth: {
        clientId: "#CLIENTID#", //This is your client ID
        authority: "https://#SHORTNAME#.b2clogin.com/#SHORTNAME#.onmicrosoft.com/#SIGNIN#", //This is your tenant info
        validateAuthority: false
    },
    cache: {
        storeAuthStateInCookie: true
    }
};

const msal = new Msal.UserAgentApplication(msalConfig);

const loginRequest = {
    scopes: appConfig.b2cScopes
};

const tokenRequest = {
    scopes: appConfig.b2cScopes
};

function signIn() {
    msal.loginPopup(loginRequest).then((response) => {
        getToken(tokenRequest).then(updateUI);
    }).catch((error) => {
        console.log(error);
    })
}

function getToken(request) {
    return msal.acquireTokenSilent(request).catch((error) => {
        console.log("acquire token popup");
        // fallback to popup when silent fails
        return msal.acquireTokenPopup(request).then((response) => {

        }).catch((popupError) => {
            console.log(popupError);
        })
    });
}

function updateUI() {
    const account = msal.getAccount();
    const email = account.idTokenClaims.emails[0];
    $('.signin').toggleClass('hidden', true);
    $('.signout').toggleClass('hidden', false);
    Shiny.setInputValue('#SHINY#', email);
}

// signout the user
function logout() {
    // Removes all sessions, need to call AAD endpoint to do full logout
    msal.logout();
}
