#' Shiny utility functions for cheetahR
#'
#' This file contains utility functions for working with cheetahR in Shiny applications.
#'
#' @name cheetahr_shiny_utils
NULL

#' Get the current data state of a cheetah grid
#'
#' Retrieves the current data state from a cheetah grid widget and converts it
#' to a data frame. This function should be called within a reactive context
#' (e.g., inside `observe`, `observeEvent`, `reactive`, or `render*` functions).
#'
#' @param id Character. The output ID of the cheetah grid widget.
#' @param session The Shiny session object. Defaults to the current session.
#' @param handle_rownames Either a logical or a character column name. If
#'   `TRUE`, the first column in the data is converted to row names using
#'   `tibble::column_to_rownames()`. If a character string, that column is
#'   used as row names. If `FALSE`, no column is converted to row names.
#'   Defaults to `FALSE`.
#'
#' @return A data frame containing the current state of the grid data,
#'   or NULL if the data state is not available.
#'
#' @details
#' The function constructs the input ID by appending `_data_state` to the
#' provided grid ID, retrieves the data from the Shiny input, and converts
#' the nested list structure to a data frame.
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' server <- function(input, output, session) {
#'   observeEvent(input$grid_data_state, {
#'     # Use first column as row names (default)
#'     current_data <- get_grid_data("grid")
#'     print(current_data)
#'   })
#'
#'   # Use a specific column as row names:
#'   current_data <- get_grid_data("grid", handle_rownames = "rownames")
#'
#'   # Do not convert any column to row names:
#'   current_data <- get_grid_data("grid", handle_rownames = FALSE)
#' }
#' }
#'
#' @export
get_grid_data <- function(
  id,
  session = shiny::getDefaultReactiveDomain(),
  handle_rownames = FALSE
) {
  input_id <- paste0(id, "_data_state")
  data_state <- session$input[[input_id]]
  if (is.null(data_state)) {
    return(NULL)
  }
  out <- as.data.frame(
    lapply(data_state, unlist),
    stringsAsFactors = FALSE
  )
  if (isTRUE(handle_rownames)) {
    # Use first column as row names
    first_col <- names(out)[1L]
    if (!is.null(first_col)) {
      out <- tibble::column_to_rownames(out, var = first_col)
    }
  } else if (is.character(handle_rownames) && length(handle_rownames) == 1L) {
    # Use specified column as row names
    if (handle_rownames %in% names(out)) {
      out <- tibble::column_to_rownames(out, var = handle_rownames)
    }
  }
  out
}
