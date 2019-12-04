
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shiny.AADB2C

<!-- badges: start -->

<!-- badges: end -->

{shiny.AADB2C} is designed to help you get started with integration
[Azure Active Directory B2C]() authentication into your shiny
application.

``` r
library(shiny.AADB2C)
```

## Installation

You can install the package with:

``` r
remotes::install_github("lockedata/shiny.AADB2C")
```

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