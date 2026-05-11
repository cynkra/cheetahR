library(shiny)
library(cheetahR)

# This example demonstrates how to retrieve the live grid data as a reactive
# data frame in Shiny using get_grid_data().
#
# There are two reactive values exposed by the grid:
#
#   1. get_grid_data("grid") — returns the *full current state* of the grid as
#      a data frame, updated whenever any cell is edited. Use this inside
#      reactive(), observe(), or render*() functions just like any other
#      reactive expression.
#
#   2. input$grid_changed_value — a named list describing the *most recent
#      single cell edit*, with fields: row, col, value, oldValue, record.
#      Useful when you only need to react to individual changes rather than
#      reading the entire data set.

ui <- fluidPage(
  h4("Editable cheetahR grid with reactive data state"),
  helpText(
    "Edit any cell in the table below. The left panel shows the full",
    "data frame returned by get_grid_data(), updated after each edit.",
    "The right panel shows the details of the most recently changed cell."
  ),
  cheetahOutput("grid"),
  uiOutput("panels")
)

server <- function(input, output, session) {
  # Render the grid with editing enabled.
  # rownames = FALSE keeps the output tidy; set to TRUE to include row names.
  output$grid <- renderCheetah({
    cheetah(mtcars, editable = TRUE, rownames = FALSE)
  })

  # get_grid_data() reads input$grid_data_state and converts it to a data
  # frame. req() prevents output from rendering before any edits are made.
  output$data_state <- renderPrint({
    req(get_grid_data("grid"))
  })

  # Render the output panels only after the first cell edit.
  # req() ensures nothing is shown until input$grid_changed_value is available.
  output$panels <- renderUI({
    req(input$grid_changed_value)
    bslib::layout_column_wrap(
      bslib::card(
        bslib::card_header("Full grid data (get_grid_data())"),
        helpText("Updates reactively after every cell edit."),
        verbatimTextOutput("data_state")
      ),
      bslib::card(
        bslib::card_header("Last changed cell (input$grid_changed_value)"),
        helpText("Shows row, col, old value, and new value of the last edit."),
        verbatimTextOutput("changed_value")
      )
    )
  })

  # input$grid_changed_value is set by the grid whenever a cell is edited.
  # It contains: row (1-based), col (1-based), value, oldValue, record.
  output$changed_value <- renderPrint({
    req(input$grid_changed_value)
  })
}

shinyApp(ui, server)
