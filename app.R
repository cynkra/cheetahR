library(shiny)
library(bslib)

# Define UI for application that draws a histogram
ui <- page_fluid(cheetahOutput("grid"))

# Define server logic
server <- function(input, output) {
  output$grid <- renderCheetah({
    cheetah(data = mtcars)
  })
}

shinyApp(ui = ui, server = server)
