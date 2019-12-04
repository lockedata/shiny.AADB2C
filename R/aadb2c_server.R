#' Generate some sample server code to view authentication results
#'
#' @param shiny_input Expected name of shiny input from JS
#'
#' @return Sample code to console and clipboard if available
#' @export
#'
#' @examples
#' aadb2c_server()
aadb2c_server <- function(shiny_input = "email") {
  code = paste0('output$email <- shiny::renderText(input$', shiny_input,')')
  if(clipr::clipr_available()){
    clipr::write_clip(code)
  }
  cat(code)
}
