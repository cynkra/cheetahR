#' Column definition utility
#'
#' Needed by \link{cheetah} to customize
#' columns individually.
#'
#' @param name Custom name.
#' @param width Column width.
#' @param min_width Column minimal width.
#' @param max_width Column max width.
#' @param column_type Column type. TBD
#' @param action Column action. TBD
#' @param style Column style.
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
  style = NULL
) {
  list(
    caption = name,
    width = width,
    minWidth = min_width,
    maxWidth = max_width,
    columnType = column_type,
    action = action,
    style = style
  )
}
