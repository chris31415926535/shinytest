.data <- rlang::.data
# import libraries
library(shiny)
library(shinymanager)

# hard-coded credentials
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
    shiny::sliderInput("numPoints", "numPoints", 1, 5000, 500)
  ),

  # main panel for displaying outputs
  shiny::mainPanel(
    # add text, plots, etc
    #
    shiny::plotOutput("testplot"),
    plotly::plotlyOutput("testplotly")
  )
)

ui <- shinymanager::secure_app(ui)

# define server logic
server <- function(input, output) {
  # make use of any of the inputs that came from the sidebarPanel
  # generate output text, plots, etc. that will be shown in the mainPanel
  #
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  print(res_auth)



  theplot <- shiny::reactive({
    ggplot2::ggplot() +
      ggplot2::geom_histogram(dplyr::tibble(x = runif(n = input$numPoints)), mapping = ggplot2::aes(x = .data$x), binwidth= .1)
  })
  output$testplot <- shiny::renderPlot(theplot())

  # output$testplotly <- plotly::renderPlotly(plotly::ggplotly(theplot))
}

# start the app
# shiny::shinyApp(ui, server, options = list(port = 4321))
shiny::shinyApp(ui, server, options = list(port = 8080))
