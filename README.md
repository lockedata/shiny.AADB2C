
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shiny.AADB2C

<!-- badges: start -->

<!-- badges: end -->

{shiny.AADB2C} is designed to help you get started with integration
[Azure Active Directory
B2C](https://azure.microsoft.com/en-us/services/active-directory-b2c/)
authentication into your shiny application.

``` r
library(shiny.AADB2C)
```

## Installation

You can install the package with:

``` r
remotes::install_github("lockedata/shiny.AADB2C")
```

## Working with AAD B2C and shiny

### Locally

{shiny} runs on 127.0.0.1:port locally but AAD B2C will only accept
<http://localhost:port> as a Redirect URL for an AAD B2C client
application. To manage this, we recommend you run
[nginx](http://nginx.org/) on your machine to route traffic from
localhost to 127.0.0.1 if this isn’t happening naturally.

To make nginx work with shiny locally, I had to change the `nginx.conf`
file and included values like:

    http {
        include       mime.types;
        default_type  application/octet-stream;
        # web socket-y stuff to make shiny work with nginx
        map $http_upgrade $connection_upgrade {
            default upgrade;
            '' close;
        }
    
        server {
            listen       80;
            server_name  localhost;
            location / {
                proxy_set_header    Host $host;
                proxy_http_version  1.1;
                # When doing local dev it's helpful to fix your shiny port
                proxy_pass http://127.0.0.1:4537;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $connection_upgrade;
                # When doing local dev it's helpful to fix your shiny port
                proxy_redirect http://127.0.0.1:4537/ http://$host/;
            }

### In production

You will need to use SSL to be able to have shiny deployed in production
with authentication as <http://localhost> is the only non-https address
allowed. Current, common approaches to putting shiny behind SSL include:

  - [Shiny Server Pro](https://rstudio.com/products/shiny-server-pro/) /
    [RStudio Connect](https://rstudio.com/products/connect/)
  - [ShinyProxy](https://www.shinyproxy.io/)
  - Container behind a routing solution / proxy e.g. [Azure Container
    Instances](https://azure.microsoft.com/en-us/services/container-instances/)
    and [Azure Application
    Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview)

## `aadb2c_js()`

The first required component is the JavaScript code that uses the
[msal.js](https://github.com/AzureAD/microsoft-authentication-library-for-js)
library to authenticate a user via a popup.

Most of the code you might want to modify to manage buttons and shiny
communication happen in the `updateUI()` function. There are
instructions to show and hide “Sign In” and “Sign Out” buttons and pass
a piece of information when authenticated to shiny as an input.

``` r
aadb2c_js(
  output_dir = "inst/app/www",
  shiny_input = "email",
  tenant = "demotenant",
  client_id = "a0cfc440-c766-43db-9ea8-40a1efbe22ac",
  signin_policy = "B2C_1_signup_signin",
  scopes = c("email","openid", "https://demotenant.onmicrosoft.com/appname/read"
)
```

### Configure authentication

To configure the JS script, you need the following pieces of
information:

  - The AAD B2C tenant name, e.g the demotenant in
    demotenant.onmicrosoft.com
  - The application ID of the AAD B2C app
  - The User Flow / Policy to use to Sign In
  - The scopes that should be requested, including a URI

You will want to use your browsers developer tools to help you get any
error mesages you might encounter. The scopes in particular can be
pesky\!

You may also want to / need to provide further configuration details.
This documentation can be found at
[docs.microsoft.com/…/msal-client-application-configuration](https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-client-application-configuration)

## Integrating the JS into shiny

Included in this package are functions providing some basic code to
demonstrate the minimum needed to provide login functionality and do
something based on the authentication.

``` r
aadb2c_ui()
#>  shiny::tagList(
#>     tags$script(src="https://alcdn.msauth.net/lib/1.1.3/js/auth.js"),
#>     shiny::tags$script(src = "www/msal.js"),
#>     shiny::actionButton("signin","Sign in",
#>                         class="signin",
#>                         onclick="signIn()"),
#>     shiny::actionButton("signout",
#>                         "Sign out",
#>                         class="signout hidden",
#>                         onclick="logout()"),
#>     shiny::textOutput("email")
#>   )
#> 
```

This includes how to:

  - call to the latest main msal.js library from Microsoft
  - include our bespoke integration code generated via `aadb2c_js()`
      - you will need to make the directory it’s stored in available to
        your shiny dashboard with `shiny::addResourcePath()`
  - buttons that appear conditionally based on authentication state
      - visibility is controlled based on class and is managed in our
        custom msal.js file
  - an output dependent on the server receiving the authentication
    details

It’s provided in a tagList but the individual functions can be included
in a general UI object.

``` r
aadb2c_server()
#> output$email <- shiny::renderText(input$email)
```

This is pretty simple - it merely translates the input created in the
msal.js when someone successfully authenticates into a text output. This
code snippet can be added to the `server()` function.
