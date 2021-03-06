#' Dashboard Page with a right sidebar
#'
#' This creates a dashboard page for use in a Shiny app.
#' 
#' @importFrom shinydashboard dashboardSidebar
#' @importFrom shinydashboard dashboardBody
#'
#' @param header A header created by \code{dashboardHeaderPlus}.
#' @param sidebar A sidebar created by \code{\link[shinydashboard]{dashboardSidebar}}.
#' @param body A body created by \code{\link[shinydashboard]{dashboardBody}}.
#' @param rightsidebar A right sidebar created by \code{rightSidebar}. NULL by
#'   default.
#' @param footer A footer created by \code{dashboardFooter}.
#' @param title A title to display in the browser's title bar. If no value is
#'   provided, it will try to extract the title from the
#'   \code{dashboardHeaderPlus}.
#' @param skin A color theme. One of \code{"blue"}, \code{"black"},
#'   \code{"purple"}, \code{"green"}, \code{"red"}, or \code{"yellow"}.
#' @param collapse_sidebar Whether to collapse the left sidebar. FALSE by
#'   default.
#' @param sidebar_background Main sidebar background color: either "light" or
#'   NULL. NULL by default.
#' @param sidebar_fullCollapse Whether to fully collapse the sidebar as with shinydashboard.
#' FALSE by default.
#' @param enable_preloader Whether to enable a page loader. FALSE by default.
#' @param loading_duration Loader duration in seconds. 2s by default.
#' @param md Whether to enable material design. Experimental...
#'
#' @seealso \code{\link{dashboardHeaderPlus}}, \code{\link[shinydashboard]{dashboardSidebar}},
#'   \code{\link[shinydashboard]{dashboardBody}}.
#' @examples
#' if (interactive()) {
#' library(shiny)
#' library(shinydashboard)
#' library(shinydashboardPlus)
#' 
#' shinyApp(
#'   ui = dashboardPagePlus(
#'     header = dashboardHeaderPlus(
#'      enable_rightsidebar = TRUE,
#'      rightSidebarIcon = "gears"
#'     ),
#'     sidebar = dashboardSidebar(),
#'     body = dashboardBody(),
#'     rightsidebar = rightSidebar(),
#'     title = "DashboardPage"
#'   ),
#'   server = function(input, output) { }
#' )
#' }
#' @export
dashboardPagePlus <- function(header, sidebar, body, rightsidebar = NULL, footer = NULL, title = NULL,
                              skin = c("blue", "blue-light","black","black-light", 
                                       "purple","purple-light", "green","green-light",
                                       "red","red-light", "yellow","yellow-light"),
                              collapse_sidebar = FALSE, sidebar_background = NULL,
                              sidebar_fullCollapse = FALSE, enable_preloader = FALSE, loading_duration = 2,
                              md = FALSE) {
  
  tagAssert(header, type = "header", class = "main-header")
  tagAssert(sidebar, type = "aside", class = "main-sidebar")
  tagAssert(body, type = "div", class = "content-wrapper")
  # tagAssert(footer, type = "footer", class = "main-footer")
  # tagAssert(controlbar, type = "aside", class = "control-sidebar")
  skin <- match.arg(skin)
  
  bodyCl <- paste0(
    "hold-transition skin-", 
    skin, 
    if (!is.null(sidebar_background)) paste0("-", sidebar_background))
  if (!sidebar_fullCollapse) bodyCl <- paste0(bodyCl, " sidebar-mini")
  if (collapse_sidebar) bodyCl <- paste0(bodyCl, " sidebar-collapse")
  
  extractTitle <- function(header) {
    x <- header$children[[1]]
    if (x$name == "span" &&
        !is.null(x$attribs$class) &&
        x$attribs$class == "logo" &&
        length(x$children) != 0)
    {
      x$children[[1]]
    } else {
      ""
    }
  }
  
  title <- title %OR% extractTitle(header)
  
  content <- shiny::tags$div(
    class = "wrapper",
    header, 
    sidebar, 
    if (enable_preloader) preloader(),
    body, 
    footer,
    rightsidebar
  )
  
  addDeps(
    md = md,
    shiny::tags$body(
      # preloader, if any
      onload = if (enable_preloader) {
        duration <- loading_duration * 1000
        paste0(
          "$(document).ready(function() {
            setTimeout(function(){
            $('body').addClass('loaded');
            $('h1').css('color','#222222');
            }, ", duration, ");
          });
          "
        )
      },
      class = bodyCl,
      style = "min-height: 611px;",
      shiny::bootstrapPage(content, title = title)
    )
  )
}