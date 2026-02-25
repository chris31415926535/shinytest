.data <- rlang::.data
# import libraries
library(shiny)
library(shinymanager)
library(ggplot2)
library(plotly)
# hard-coded credentials
#
use_login <- TRUE

credentials <- data.frame(
  user = c("bdssf", "christopher"), # mandatory
  password = c("bdssf2026", "belmonts"), # mandatory
  admin = c(FALSE, TRUE)
)
# possibly read in some data to be used below

# define the UI
ui <- shiny::fluidPage(
  # app title
  shiny::headerPanel("BDSSF Test"),

  # sidebar panel for inputs
  shiny::sidebarPanel(
    # add dropdowns, sliders, checkboxes, radio buttons, etc.
    #
    shiny::radioButtons("distribution", "Distribution:", choices = c("Uniform", "Normal")),
    shiny::sliderInput("numPoints", "# of Points:", 1, 5000, 500)
  ),

  # main panel for displaying outputs
  shiny::mainPanel(
    # add text, plots, etc
    #
    plotly::plotlyOutput("testplotly")
  )
)

if (use_login) {
  ui <- shinymanager::secure_app(ui)
}

# define server logic
server <- function(input, output) {
  # make use of any of the inputs that came from the sidebarPanel
  # generate output text, plots, etc. that will be shown in the mainPanel
  #
  # check_credentials returns a function to authenticate users
  if (use_login) {
    res_auth <- secure_server( # nolint 
      check_credentials = check_credentials(credentials)
    )
  }

  points <- shiny::reactive({
    if (input$distribution == "Normal") {
      rnorm(n = input$numPoints, mean = 0.5, sd = 0.25)
    } else if (input$distribution == "Uniform") {
      runif(n = input$numPoints)
    }
  })

  theplot <- shiny::reactive({
    shiny::req(points())
    p <- ggplot2::ggplot() +
      ggplot2::geom_histogram(
        dplyr::tibble(
          x = points()
        ),
        mapping = ggplot2::aes(
          x = .data$x
        ), binwidth = .1, boundary = 0
      ) +
      ggplot2::theme(plot.margin = ggplot2::margin_auto()) ### MUST ADD THIS FOR GGPLOTLY!!!!!!!

    if (input$distribution == "Uniform") {
      p <- p + ggplot2::scale_x_continuous(limits = c(0, 1))
    } else {
      p <- p + ggplot2::scale_x_continuous(limits = c(-0.5, 1.5))
    }

    p
  })

  output$testplot <- shiny::renderPlot(theplot())
  output$testplotly <- plotly::renderPlotly(plotly::ggplotly(theplot()))
}

# start the app
# shiny::shinyApp(ui, server, options = list(port = 4321, host="0.0.0.0"))
shiny::shinyApp(ui, server, options = list(port = 8080, host = "0.0.0.0"))
