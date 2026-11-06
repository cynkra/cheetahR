library(shiny)
library(bslib)
library(cheetahR)

# This example demonstrates how to add and delete rows with cheetah_proxy()
# without re-rendering the whole grid.
#
#   1. cheetah_proxy("grid") creates a handle to an already rendered grid.
#   2. add_row(proxy, data) appends a one-row data frame to the grid.
#   3. delete_row(proxy, row_index) removes the row at a 1-based index.
#
# Proxy changes are also reflected in get_grid_data("grid"), so the live data
# frame stays in sync with what the user sees.

ui <- page_sidebar(
  sidebar = sidebar(
    actionButton("add_row", "Add row"),
    actionButton("delete_row", "Delete clicked row"),
    helpText("Click a cell first to choose which row to delete.")
  ),
  card(cheetahOutput("grid")),
  card(
    card_header("Full grid data (get_grid_data())"),
    verbatimTextOutput("data_state")
  )
)

server <- function(input, output, session) {
  # Render the grid only once. Later changes go through the proxy.
  output$grid <- renderCheetah({
    cheetah(iris[sample(nrow(iris), 10), ], editable = TRUE, rownames = FALSE)
  })

  proxy <- cheetah_proxy("grid")

  # Add a random row
  observeEvent(input$add_row, {
    new_row <- data.frame(
      Sepal.Length = round(runif(1, 4, 8), 1),
      Sepal.Width = round(runif(1, 2, 4.5), 1),
      Petal.Length = round(runif(1, 1, 7), 1),
      Petal.Width = round(runif(1, 0.1, 2.5), 1),
      Species = sample(levels(iris$Species), 1)
    )
    add_row(proxy, new_row)
  })

  # Delete the row of the last clicked cell. req() prevents an error when
  # no cell has been clicked yet.
  observeEvent(input$delete_row, {
    req(input$grid_click_cell)
    row_index <- input$grid_click_cell[["row"]]
    if (row_index > 0) {
      delete_row(proxy, row_index)
    }
  })

  output$data_state <- renderPrint({
    req(get_grid_data("grid"))
  })
}

shinyApp(ui, server)
