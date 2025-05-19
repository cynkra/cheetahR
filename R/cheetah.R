#' Create a Cheetah Grid widget
#'
#' Creates a high-performance table widget using Cheetah Grid.
#'
#' @param data A data frame or matrix to display
#' @param columns A list of column definitions. Each column can be customized using
#'   \code{column_def()}.
#' @param column_group A list of column groups. Each group can be customized using
#' @param width Width of the widget
#' @param height Height of the widget
#' @param elementId The element ID for the widget
#' @param rownames Logical. Whether to show rownames. Defaults to TRUE.
#' @param search Whether to enable a search field on top of the table.
#' Default to `disabled`. Use `exact` for exact matching
#' or `contains` to get larger matches.
#' @param sortable Logical. Whether to enable sorting on all columns. Defaults to TRUE.
#' @param editable Logical. Whether to enable cell editing. Defaults to FALSE.
#' @param disable_column_resize Logical. Whether to disable column resizing. Defaults to FALSE.
#' @param column_freeze Integer. The number of columns to freeze from the left.
#' @param default_row_height Integer. The default row height.
#' @param default_col_width Integer. The default column width.
#' @param header_row_height Integer. The header row height.
#' @param theme The theme to use for the widget. Provide a named list of valid styling options to customize the widget.
#' For possible options, see \href{https://future-architect.github.io/cheetah-grid/documents/api/js/theme.html#extend-theme}{Extend Theme in Cheetah Grid}
#' @param font A String. The font to use for the widget. This is possible to set a font value according
#' to the standard CSS font properties shorthand declaration. For example, `font = "12px Arial, sans-serif"`.
#' This means that the font size is 12px, the font family is Arial, and the font weight is normal.
#' @param underlay_background_color The underlay background color of the widget.
#' @param allow_range_paste Logical. Whether to allow range pasting. Defaults to FALSE.
#' To activate this option set `editable = TRUE` or ensure a given column is editable.
#' @param keyboard_options A named list of keyboard options. There are four options:
#' \itemize{
#'   \item `moveCellOnTab`. Set to `TRUE` to enable cell movement by Tab key.
#'   \item `moveCellOnEnter`. Set to `TRUE` to enable cell movement by Enter key.
#'   \item `deleteCellValueOnDel`. Set to `TRUE` to enable deletion of cell values with the Delete and BackSpace keys.
#'   Note that this will only work if `editable` is `TRUE` or a given column is editable.
#'   \item `selectAllOnCtrlA`. Set to `TRUE` to enable select all cells by 'Ctrl + A key.
#' }
#' @return An HTML widget object of class 'cheetah' that can be:
#'   \itemize{
#'     \item Rendered in R Markdown documents
#'     \item Used in Shiny applications
#'     \item Displayed in R interactive sessions
#'   }
#'   The widget renders as an HTML table with all specified customizations.
#'
#' @examples
#' # Basic usage
#' cheetah(iris)
#'
#' # Customize columns
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
#' # Customize rownames
#' cheetah(
#'   mtcars,
#'   columns = list(
#'     rownames = column_def(width = 150, style = list(color = "red"))
#'   )
#' )
#'
#' # Customize column groups
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
#' # Enable search
#' cheetah(iris, search = "contains")
#'
#' # Enable sorting
#' cheetah(iris, sortable = TRUE)
#'
#' # Enable cell editing
#' cheetah(iris, editable = TRUE)
#'
#' # Disable column resizing
#' cheetah(iris, disable_column_resize = TRUE)
#'
#' # Freeze columns
#' cheetah(iris, column_freeze = 2)
#'
#' # Set default row height
#' cheetah(iris, default_row_height = 30)
#'
#' @import htmlwidgets
#' @import jsonlite
#' @import tibble
#'
#' @export
cheetah <- function(
  data,
  columns = NULL,
  column_group = NULL,
  width = NULL,
  height = NULL,
  elementId = NULL,
  rownames = TRUE,
  search = c("disabled", "exact", "contains"),
  sortable = TRUE,
  editable = FALSE,
  disable_column_resize = FALSE,
  column_freeze = NULL,
  default_row_height = NULL,
  default_col_width = NULL,
  header_row_height = NULL,
  theme = NULL,
  font = NULL,
  underlay_background_color = NULL,
  allow_range_paste = FALSE,
  keyboard_options = NULL
) {
  search <- match.arg(search)

  stopifnot(
    "`keyboard_options` must be a named list" =
      is.null(keyboard_options) |
      is_named_list(keyboard_options)
  )
  stopifnot("`theme` must be a named list" =
    is.null(theme) |
    is_named_list(theme)
  )
  # Only show rownames if they are character strings (meaningful) and rownames is TRUE
  processed_rn <- process_rownames(data, columns, rownames)

  data <- processed_rn$data
  columns <- processed_rn$columns

  stopifnot(
    is.null(columns) |
      is_named_list(columns) & names(columns) %in% colnames(data)
  )

  stopifnot(
    "If not NULL, `column_groups` must be a named list or list of named lists" =
      is.null(columns) |
      is_named_list(column_group) |
      all(unlist(lapply(column_group, is_named_list)))
  )

  columns <-
    update_col_list_with_classes(data, columns) %>%
    make_table_sortable(sortable = sortable) %>%
    make_table_editable(editable = editable) %>%
    auto_set_column_width(default_col_width = default_col_width) %>%
    add_field_to_list()

  data_json <- toJSON(data, dataframe = "rows")
  # forward options using x
  x <-
    dropNulls(list(
      data = data_json,
      columns = columns,
      colGroup = column_group,
      search = search,
      disableColumnResize = disable_column_resize,
      frozenColCount = column_freeze,
      defaultRowHeight = default_row_height,
      defaultColWidth = default_col_width,
      headerRowHeight =  header_row_height,
      theme = theme,
      font = font,
      underlayBackgroundColor = underlay_background_color,
      allowRangePaste = allow_range_paste,
      keyboardOptions = keyboard_options
    ))

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
#' @return \code{cheetahOutput} returns a Shiny output function that can be used in the UI definition.
#'   \code{renderCheetah} returns a Shiny render function that can be used in the server definition.
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
renderCheetah <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, cheetahOutput, env, quoted = TRUE)
}
