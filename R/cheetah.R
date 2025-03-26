#' Cheetah
#'
#' Some description.
#'
#' @param data Data
#' @param columns Columns
#' @param width Width
#' @param height Height
#' @param elementId Element ID
#'
#' @import htmlwidgets
#' @import jsonlite
#'
#' @export
cheetah <- function(
  data,
  columns = NULL,
  width = NULL,
  height = NULL,
  elementId = NULL
) {
  stopifnot(
    is.null(columns) |
      is_named_list(columns) & names(columns) %in% colnames(data)
  )
  columns <- toJSON(add_field_to_list(columns), auto_unbox = TRUE)
  data <- toJSON(data, dataframe = "rows")
  # forward options using x
  x = list(data = data, columns = columns)

  # create widget
  htmlwidgets::createWidget(
    name = 'cheetah',
    x = x,
    width = width,
    height = height,
    package = 'cheetahR',
    elementId = elementId
  )
}

#' Shiny bindings for cheetah
#'
#' Output and render functions for using cheetah within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a cheetah
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name cheetah-shiny
#'
#' @export
cheetahOutput <- function(outputId, width = '100%', height = '400px') {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    'cheetah',
    width,
    height,
    package = 'cheetahR'
  )
}

#' @rdname cheetah-shiny
#' @export
rendercheetah <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, cheetahOutput, env, quoted = TRUE)
}
