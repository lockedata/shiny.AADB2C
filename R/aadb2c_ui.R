#' Generate some sample UI code to perform authentication
#'
#' @return Sample code to console and clipboard if available
#' @export
#'
#' @examples
#' aadb2c_ui()
aadb2c_ui <- function() {
  code = ' shiny::tagList(
    tags$script(src="https://alcdn.msauth.net/lib/1.1.3/js/auth.js"),
    shiny::tags$script(src = "www/msal.js"),
    shiny::actionButton("signin","Sign in",
                        class="signin",
                        onclick="signIn()"),
    shiny::actionButton("signout",
                        "Sign out",
                        class="signout hidden",
                        onclick="logout()"),
    shiny::textOutput("email")
  )
  '
  if(clipr::clipr_available()){
    clipr::write_clip(code)
  }
  cat(code)
}
