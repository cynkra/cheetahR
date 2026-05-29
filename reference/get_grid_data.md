# Get the current data state of a cheetah grid

Retrieves the current data state from a cheetah grid widget and converts
it to a data frame. This function should be called within a reactive
context (e.g., inside `observe`, `observeEvent`, `reactive`, or
`render*` functions).

## Usage

``` r
get_grid_data(
  id,
  session = shiny::getDefaultReactiveDomain(),
  handle_rownames = FALSE
)
```

## Arguments

- id:

  Character. The output ID of the cheetah grid widget.

- session:

  The Shiny session object. Defaults to the current session.

- handle_rownames:

  Either a logical or a character column name. If `TRUE`, the first
  column in the data is converted to row names using
  [`tibble::column_to_rownames()`](https://tibble.tidyverse.org/reference/rownames.html).
  If a character string, that column is used as row names. If `FALSE`,
  no column is converted to row names. Defaults to `FALSE`.

## Value

A data frame containing the current state of the grid data, or NULL if
the data state is not available.

## Details

The function constructs the input ID by appending `_data_state` to the
provided grid ID, retrieves the data from the Shiny input, and converts
the nested list structure to a data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
server <- function(input, output, session) {
  observeEvent(input$grid_data_state, {
    # Use first column as row names (default)
    current_data <- get_grid_data("grid")
    print(current_data)
  })

  # Use a specific column as row names:
  current_data <- get_grid_data("grid", handle_rownames = "rownames")

  # Do not convert any column to row names:
  current_data <- get_grid_data("grid", handle_rownames = FALSE)
}
} # }
```
