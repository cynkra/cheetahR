library(shiny)
library(dplyr)
library(cheetahR)

ui <- fluidPage(
  helpText("Edit cell values to retrieve the data state"),
  cheetahOutput("grid"),
  bslib::layout_column_wrap(
    verbatimTextOutput("data_state"),
    verbatimTextOutput("changed_value")
  )
)

server <- function(input, output, session) {
  output$grid <- renderCheetah({
    cheetah(mtcars, editable = TRUE, rownames = FALSE)
  })

  output$data_state <- renderPrint({
    req(get_grid_data("grid"))
  })

  output$changed_value <- renderPrint({
    req(input$grid_changed_value)
  })
}

shinyApp(ui, server)
