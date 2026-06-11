library(shiny)
library(cheetahR)

# This example puts two interactive column types side by side so you can
# compare how each behaves:
#
#   - `country` uses `action = "autocomplete"`: the user types and sees
#     matching suggestions filtered from a fixed list. Use it when the pool
#     of valid values is too large for a regular dropdown.
#   - `region` uses `column_type = "menu"` + `action = "inline_menu"`:
#     the user picks from a small, closed list of options.
#
# Both columns are editable. After any edit, `input$grid_changed_value` holds
# the most recent single-cell change and `get_grid_data("grid")` returns the
# full grid as a reactive data frame.

# Pool of values the user can pick from for the autocomplete column.
countries <- c(
  "Argentina",
  "Australia",
  "Brazil",
  "Canada",
  "Chile",
  "China",
  "Denmark",
  "Egypt",
  "France",
  "Germany",
  "Ghana",
  "India",
  "Indonesia",
  "Ireland",
  "Italy",
  "Japan",
  "Kenya",
  "Mexico",
  "Netherlands",
  "Nigeria",
  "Norway",
  "Portugal",
  "Spain",
  "Sweden",
  "Switzerland",
  "Uganda",
  "United Kingdom",
  "United States"
)

# `country` is a character column (required for autocomplete); `region` is a
# small closed set, which is a natural fit for an inline_menu dropdown.
data <- data.frame(
  id = 1:6,
  country = c("France", "Germany", "Ghana", "India", "Italy", "Japan"),
  region = c("Europe", "Europe", "Africa", "Asia", "Europe", "Asia"),
  population_m = c(67, 84, 33, 1428, 59, 125),
  stringsAsFactors = FALSE
)

ui <- fluidPage(
  h4("Autocomplete vs. inline_menu"),
  helpText(
    "Click a cell in 'country' (autocomplete) to filter suggestions as you",
    "type, or a cell in 'region' (inline_menu) to pick from a fixed dropdown."
  ),
  cheetahOutput("grid"),
  h5("Last changed cell"),
  verbatimTextOutput("last_change"),
  h5("Current data state"),
  verbatimTextOutput("data_state")
)

server <- function(input, output, session) {
  output$grid <- renderCheetah({
    cheetah(
      data,
      editable = TRUE,
      rownames = FALSE,
      # Optional: let Tab also move the selection to the next cell.
      keyboard_options = list(moveCellOnTab = TRUE),
      columns = list(
        country = column_def(
          action = "autocomplete",
          auto_complete_opts = countries
        ),
        region = column_def(
          column_type = "menu",
          action = "inline_menu",
          menu_options = list(
            Africa = "Africa",
            Americas = "Americas",
            Asia = "Asia",
            Europe = "Europe",
            Oceania = "Oceania"
          )
        )
      )
    )
  })

  # Reactive: most recent single-cell edit.
  output$last_change <- renderPrint({
    req(input$grid_changed_value)
    input$grid_changed_value
  })

  # Reactive: the full grid as a data frame, updated after every edit.
  output$data_state <- renderPrint({
    req(get_grid_data("grid"))
  })
}

shinyApp(ui, server)
