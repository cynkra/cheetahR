#' Column definition utility
#'
#' Needed by \link{cheetah} to customize
#' columns individually.
#'
#' @param name Custom name.
#' @param width Column width.
#' @param min_width Column minimal width.
#' @param max_width Column max width.
#' @param column_type Column type. There are 6 possible options:
#' \itemize{
#'   \item \code{"text"} for text columns.
#'   \item \code{"number"} for numeric columns.
#'   \item \code{"check"} for check columns.
#'   \item \code{"image"} for image columns.
#'   \item \code{"radio"} for radio columns.
#'   \item \code{"multilinetext"} for multiline text in columns.
#' }
#' @param action The action property defines column actions. Select
#' the appropriate Action class for the column type. For instance,
#' if the column type is \code{"text"}, the action can be \code{"input"}.
#' There are 3 supported actions:
#' \itemize{
#'   \item \code{"input"} for input action columns.
#'   \item \code{"check"} for check action columns.
#'   \item \code{"radio"} for radio action columns.
#' }
#' @param style Column style.
#' @param message Cell message. Expect a [htmlwidgets::JS()] function that
#' takes `rec` as argument. It must return an object with two properties: `type` for the message
#' type (`"info"`, `"warning"`, `"error"`) and the `message` that holds the text to display.
#' The latter can leverage a JavaScript ternary operator involving `rec.<COLNAME>` (`COLNAME` being the name
#' of the column for which we define the message) to check whether the predicate function is TRUE.
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
#' @param sort Whether to sort the column. Default to FALSE. May also be
#' a JS callback to create custom logic (does not work yet).
#'
#' @export
#' @return A list of column options to pass to the JavaScript API.
column_def <- function(
  name = NULL,
  width = NULL,
  min_width = NULL,
  max_width = NULL,
  column_type = NULL,
  action = NULL,
  style = NULL,
  message = NULL,
  sort = FALSE
) {
  check_column_type(column_type)
  if (!is.null(message) && !inherits(message, "JS_EVAL"))
    stop("message must be a JavaScript function wrapped by htmlwidgets::JS().")
  list(
    caption = name,
    width = width,
    minWidth = min_width,
    maxWidth = max_width,
    columnType = column_type,
    action = action,
    style = style,
    message = message
    sort = sort
  )
}
