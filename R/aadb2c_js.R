#' Generate some initial JS code to authenticate against AAD B2C
#'
#' @param shiny_input The id of the input that should be given the user's email
#' @param output_dir Where the JS file should be output
#' @param tenant The AAD B2C tenant name (no onmicrosoft.com bit)
#' @param client_id The application ID of the AAD B2C app
#' @param signin_policy The User Flow / Policy to use to Sign In
#' @param scopes The scopes that should be requested, including a URI. Typically
#'   the URI is a variant of the App API URI
#'
#' @return Configured JS file's location
#' @export
#'
#' @examples
#' on.exit(aadb2c_js(tempdir()), unlink(tempdir()))
aadb2c_js <- function(output_dir=".",
  shiny_input = "email",
  tenant = "shortname",
  client_id = "guid",
  signin_policy = "B2C_1_signup_signin",
  scopes = c("email","openid", "https://someresource/read")
  ){
  js = readLines(system.file("templates","msal.js",package = "shiny.AADB2C"))
  js = gsub("#CLIENTID#", client_id, js, fixed=TRUE)
  js = gsub("#SHORTNAME#", tenant, js, fixed=TRUE)
  js = gsub("#SIGNIN#", signin_policy, js, fixed=TRUE)
  js = gsub("#SHINY#", shiny_input, js, fixed=TRUE)
  js = gsub("#CLIENTID#", client_id, js, fixed=TRUE)
  js = gsub("#SCOPES#",
            paste0("'",paste(scopes, collapse = "', "),"'")
            , js, fixed=TRUE)

  writeLines(js, file.path(output_dir, "msal.js"))
  return(file.path(output_dir, "msal.js"))
}
