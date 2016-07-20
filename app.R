#
# This is a Shiny web application.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyTime)
library(magrittr)

getCRANVersion <- function(package) {
  package_info <- paste0("http://crandb.r-pkg.org", "/", package) %>%
    httr::GET() %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  package_info$Version
}

ui <- fluidPage(

   titlePanel("shinyTime Example App"),

   sidebarLayout(
      sidebarPanel(
        timeInput("time_input", "Enter time", value = strptime("12:34:56", "%T")),
        actionButton("to_current_time", "Current time"),
        hr(),
        tags$b("shinyTime:"),
        textOutput("installed_version"),
        textOutput("cran_version"),
        helpText(a("Project page", href = "https://github.com/burgerga/shinyTime"))
      ),

      mainPanel(
        textOutput("time_output")
      )
   )
)

server <- function(input, output, session) {
  output$time_output <- renderText(strftime(input$time_input, "%T"))

  currentCranVersion <- reactive({
    invalidateLater(60 * 60 * 1000, session)
    getCRANVersion('shinyTime')
  })

  output$installed_version <- renderText(paste("Installed version:", packageVersion('shinyTime')))
  output$cran_version <- renderText(paste("CRAN version: ", currentCranVersion()))

  observeEvent(input$to_current_time, {
    updateTimeInput(session, "time_input", value = Sys.time())
  })
}

shinyApp(ui, server)

