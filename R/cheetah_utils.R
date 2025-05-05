#' Column definition utility
#'
#' Needed by \link{cheetah} to customize
#' columns individually.
#'
#' @param name Custom name.
#' @param width Column width.
#' @param min_width Column minimal width.
#' @param max_width Column max width.
#' @param column_type Column type. By default, the column type is inferred from the data type of the column.
#' There are 7 possible options:
#' \itemize{
#'   \item \code{"text"} for text columns.
#'   \item \code{"number"} for numeric columns.
#'   \item \code{"check"} for check columns.
#'   \item \code{"image"} for image columns.
#'   \item \code{"radio"} for radio columns.
#'   \item \code{"multilinetext"} for multiline text columns.
#'   \item \code{"menu"} for menu selection columns. If \code{column_type == "menu"},
#'    action parameter must be set to "inline_menu" and menu_options must be provided.
#'    Note: Works efficiently only in shiny.
#' }
#' @param action The action property defines column actions. Select
#' the appropriate Action class for the column type.
#' \itemize{
#'   \item \code{"input"} for input action columns.
#'   \item \code{"check"} for check action columns.
#'   \item \code{"radio"} for radio action columns.
#'   \item \code{"inline_menu"} for menu selection columns.
#' }
#' @param menu_options A list of menu options when using \code{column_type = "menu"}.
#' Each option should be a list with \code{value} and \code{label} elements.
#' The menu options must be a list of lists, each containing a \code{value}
#' and \code{label} element.
#' The \code{label} element is the label that will be displayed in the menu.
#' @param style Column style.
#' @param message Cell message. Expect a [htmlwidgets::JS()] function that
#' takes `rec` as argument. It must return an object with two properties: `type` for the message
#' type (`"info"`, `"warning"`, `"error"`) and the `message` that holds the text to display.
#' The latter can leverage a JavaScript ternary operator involving `rec.<COLNAME>` (`COLNAME` being the name
#' of the column for which we define the message) to check whether the predicate function is TRUE. You can also
#' use `add_cell_message()` to generated the expected JS expression.
#' See details for example of usage.
#'
#' @details
#' ## Cell messages
#' When you write a message, you can pass a function like so:
#' ```
#'   <COLNAME> = column_def(
#'     action = "input",
#'      message = JS(
#'       "function(rec) {
#'          return {
#'            //info message
#'            type: 'info',
#'            message: rec.<COLNAME> ? null : 'Please check.',
#'          }
#'        }")
#'     )
#' ```
#' Or use `add_cell_message()`:
#' ```
#'   <COLNAME> = column_def(
#'     action = "input",
#'      message = add_cell_message(type = "info", message = "Ok")
#'     )
#' ```
#' See [add_cell_message()] for more details.
#' @param sort Whether to sort the column. Default to FALSE. May also be
#' a JS callback to create custom logic (does not work yet).
#'
#' @return A list of column options to pass to the JavaScript API.
#'
#' @examples
#' cheetah(
#'   iris,
#'   columns = list(
#'     Sepal.Length = column_def(name = "Length"),
#'     Sepal.Width = column_def(name = "Width"),
#'     Petal.Length = column_def(name = "Length"),
#'     Petal.Width = column_def(name = "Width")
#'   )
#' )
#'
#' @export
column_def <- function(
  name = NULL,
  width = NULL,
  min_width = NULL,
  max_width = NULL,
  column_type = NULL,
  action = NULL,
  menu_options = NULL,
  style = NULL,
  message = NULL,
  sort = FALSE
) {
  check_column_type(column_type)
  check_action_type(action, column_type)
  in_shiny <- shiny::isRunning()

  if (all(!is.null(column_type), column_type == "menu", !in_shiny)) {
    warning(
      "Dropdown menu action does not work properly outside a shiny environment"
    )
  }

  if (
    all(!is.null(column_type), column_type == "menu", is.null(menu_options))
  ) {
    stop("menu_options must be provided when column_type is 'menu'")
  }

  if (!is.null(message) && !inherits(message, "JS_EVAL")) {
    stop("message must be a JavaScript function wrapped by htmlwidgets::JS().")
  }

  list(
    caption = name,
    width = width,
    minWidth = min_width,
    maxWidth = max_width,
    columnType = column_type,
    action = if (!is.null(action)) {
      if (action == "inline_menu") {
        list(
          type = action,
          options = menu_options
        )
      } else {
        action
      }
    },
    style = style,
    message = message,
    sort = sort
  )
}

#' Column group definitions
#'
#' Creates a column group definition for grouping columns in a Cheetah Grid widget.
#'
#' @param name Character string. The name to display for the column group.
#' @param columns Character vector. The names of the columns to include in this group.
#' @param header_style Named list of possibleCSS style properties to apply to the column group header.
#'
#' @return A list containing the column group definition.
#'
#' @examples
#' cheetah(
#'   iris,
#'   columns = list(
#'     Sepal.Length = column_def(name = "Length"),
#'     Sepal.Width = column_def(name = "Width"),
#'     Petal.Length = column_def(name = "Length"),
#'     Petal.Width = column_def(name = "Width")
#'   ),
#'   column_group = list(
#'     column_group(name = "Sepal", columns = c("Sepal.Length", "Sepal.Width")),
#'     column_group(name = "Petal", columns = c("Petal.Length", "Petal.Width"))
#'   )
#' )
#'
#' @export
column_group <- function(name = NULL, columns, header_style = NULL) {
  column_style_check(header_style)

  dropNulls(
    list(
      caption = name,
      columns = columns,
      headerStyle = header_style
    )
  )
}
