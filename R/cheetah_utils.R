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


#' Column formatter
#'
#' Format numeric and date columns using international formatting standards.
#' Use `number_format()` to add data formatting to numeric columns and
#' `date_format()` to format date columns according to the Intl.DateTimeFormat API.
#'
#' @param style The formatting style to use. Must be one of the following:
#' \itemize{
#'   \item `"decimal"` for plain number formatting action columns. Default.
#'   \item `"currency"` for currency formatting
#'   \item `"percent"` for percent formatting.
#'   \item `"unit"` for unit formatting.
#' }
#' @param currency The ISO 4217 currency code to use for currency formatting. Must be provided if `style` is `"currency"`.
#' @param currency_display The display format for the currency. Must be one of the following:
#'   \itemize{
#'     \item `"symbol"` for the currency symbol. Default. Use the localized currency symbol e.g. $ for USD.
#'     \item `"code"` for the currency code. Use the ISO 4217 currency code e.g. USD for US Dollar.
#'     \item `"narrowSymbol"` for the narrow currency symbol. Use the narrow currency symbol e.g. `$100` instead of `$USD100`.
#'     \item `"name"` for the currency name. Use the localized currency name e.g. Dollar for USD.
#'   }
#' @param currency_sign The sign to use for the currency. Must be one of the following:
#'   \itemize{
#'     \item `"standard"` for the standard format. Default.
#'     \item `"accounting"` for the accounting format. Use the accounting sign e.g. $100 instead of $USD100.
#'   }
#' @param unit The unit to use for the unit formatting. Must be provided if `style` is `"unit"`.
#' @param unit_display The display format for the unit. Must be one of the following:
#'   \itemize{
#'     \item `"short"` for the short format. Default. E.g., 16 l
#'     \item `"narrow"` for the narrow format. E.g., 16l
#'     \item `"long"` for the long format. E.g., 16 liters
#'   }
#' @param locales A character vector of BCP 47 language tags (e.g. `"en-US"` for English,
#'   `"ja-JP"` for Japanese) specifying the locales to use for formatting.
#'   If NULL, the runtime's default locale is used. See
#'   [BCP 47 language tags](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/6c085406-a698-4e12-9d4d-c3b0ee3dbc4a)
#'   for reference.
#' @param locale_options A named list of options to customize the locale.
#' @param digit_options A named list of options to customize the digit.
#' @param other_options A named list of other options to customize the number formatting.
#' @param day,month,year,hour,minute,second The format to use for the day, month,
#' year, hour, minute, and second. The possible values are `"numeric"`, and `"2-digit"`
#' except month, with more options i.e `"long"`, `"short"`, and `"narrow"`.
#' Default for all is `"numeric"`.
#' @param weekday,day_period The format to use for the weekday and day period.
#' The possible values are `"long"`, `"short"`, and `"narrow"`.
#' @param date_style,time_style The format to use for the date and time styles.
#' The available values are `"none"`, `"full"`, `"long"`, `"medium"`, and `"short"`.
#' Note: date_style and time_style can be used together,
#' but not with other date-time component options like weekday, hour, or month.
#' @param hour12 Whether to use 12-hour time format or the 24-hour format. Default is FALSE.
#' @param time_zone The time zone to use for the date formatting. E.g. `"America/New_York"`.
#' @param more_date_options A named list of other options to customize the date formatting.
#' @param locales_date_options A named list of options to customize the locales for the date.
#'  @note
#'  Further details on customizing numeric formatting can be found in the
#'  [Intl.NumberFormat documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat/NumberFormat#parameters).
#'  Further details on customizing date formatting can be found in the
#'  [Intl.DateTimeFormat documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat/DateTimeFormat)
#' @return For `number_format()`: A list containing number formatting options that can be used to format numeric data in a column.
#' For `date_format()`: A list containing date formatting options that can be used to format date data in a column.
#' @examples
#' # Number formatting examples
#' data <- data.frame(
#'   price_USD = c(125000.75, 299.99, 7890.45),
#'   price_EUR = c(410.25, 18750.60, 1589342.80),
#'   liter = c(20, 35, 42),
#'   percent = c(0.875, 0.642, 0.238)
#' )
#'
#' cheetah(
#'   data,
#'   columns = list(
#'     price_USD = column_def(
#'       name = "USD",
#'       column_type = number_format(
#'         style = "currency",
#'         currency = "USD"
#'       )
#'     ),
#'     price_EUR = column_def(
#'       name = "EUR",
#'       column_type = number_format(
#'         style = "currency",
#'         currency = "EUR",
#'         locales = "de-DE"
#'       )
#'     ),
#'     liter = column_def(
#'       name = "Liter",
#'       column_type = number_format(
#'         style = "unit",
#'         unit = "liter",
#'         unit_display = "long"
#'       )
#'     ),
#'     percent = column_def(
#'       name = "Percent",
#'       column_type = number_format(style = "percent")
#'     )
#'   )
#' )
#'
#' # Date formatting examples
#' date_data <- data.frame(
#'   date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03"))
#' )
#'
#' cheetah(
#'   date_data,
#'   columns = list(
#'     date = column_def(
#'       name = "Date",
#'       column_type = date_format(
#'         locales = "en-US",
#'         day = "2-digit",
#'         month = "long",
#'         year = "numeric"
#'       )
#'     )
#'   )
#' )
#'
#' @export
number_format <- function(
  style = c("decimal", "currency", "percent", "unit"),
  currency = NULL,
  currency_display = c("symbol", "code", "narrowSymbol", "name"),
  currency_sign = c("standard", "accounting"),
  unit = NULL,
  unit_display = c("short", "narrow", "long"),
  locales = NULL,
  locale_options = NULL,
  digit_options = NULL,
  other_options = NULL
) {
  style <- match.arg(style)
  currency_display <- match.arg(currency_display)
  currency_sign <- match.arg(currency_sign)
  unit_display <- match.arg(unit_display)

  if (style == "currency" && is.null(currency)) {
    stop(
      "`currency` specify the ISO 4217 currency code.
         E.g., 'USD' for US Dollar or 'EUR' for the euro"
    )
  }

  if (style == "unit" && is.null(unit)) {
    stop(
      "`unit` specify the unit to use for the unit formatting.
         E.g., 'liters' or 'kilograms'"
    )
  }

  if (!is.null(locales) && !is.character(locales)) {
    stop("`locales` must be a character string")
  }

  if (!is.null(locale_options) && !is_named_list(locale_options)) {
    stop("`locale_options` must be a named list")
  }

  if (!is.null(digit_options) && !is_named_list(digit_options)) {
    stop("`digit_options` must be a named list")
  }

  if (!is.null(other_options) && !is_named_list(other_options)) {
    stop("`other_options` must be a named list")
  }

  params <- list(
    style = style,
    currency = currency,
    currencyDisplay = currency_display,
    currencySign = currency_sign,
    unit = unit,
    unitDisplay = unit_display,
    locales = if (is.null(locales)) get_bcp47_locale() else locales,
    options = c(locale_options, digit_options, other_options)
  )
  params <- dropNulls(params)
  structure(params, class = "numFormat")
}


#' @rdname number_format
#' @export
date_format <- function(
  locales = NULL,
  day = c("numeric", "2-digit"),
  year = c("numeric", "2-digit"),
  hour = c("numeric", "2-digit"),
  minute = c("numeric", "2-digit"),
  second = c("numeric", "2-digit"),
  month = c("numeric", "2-digit", "long", "short", "narrow"),
  weekday = c("long", "short", "narrow"),
  day_period = c("narrow", "long", "short"),
  hour12 = FALSE,
  time_zone = NULL,
  date_style = c("none", "full", "long", "medium", "short"),
  time_style = c("none", "full", "long", "medium", "short"),
  more_date_options = NULL,
  locales_date_options = NULL
) {
  weekday <- match.arg(weekday)
  day <- match.arg(day)
  month <- match.arg(month)
  year <- match.arg(year)
  hour <- match.arg(hour)
  minute <- match.arg(minute)
  second <- match.arg(second)
  day_period <- match.arg(day_period)
  date_style <- match.arg(date_style)
  time_style <- match.arg(time_style)

  if (!is.null(hour12) && !is.logical(hour12)) {
    stop("`hour12` must be a logical value")
  }

  if (!is.null(locales_date_options) && !is_named_list(locales_date_options)) {
    stop("`locales_date_options` must be a named list")
  }

  if (!is.null(more_date_options) && !is_named_list(more_date_options)) {
    stop("`more_date_options` must be a named list")
  }
  style_time <- any(date_style != "none", time_style != "none")
  params <- list(
    locales = if (is.null(locales)) get_bcp47_locale() else locales,
    weekday = if (style_time) NULL else weekday,
    day = if (style_time) NULL else day,
    month = if (style_time) NULL else month,
    year = if (style_time) NULL else year,
    hour = if (style_time) NULL else hour,
    minute = if (style_time) NULL else minute,
    second = if (style_time) NULL else second,
    dayPeriod = if (style_time) NULL else day_period,
    hour12 = hour12,
    timeZone = time_zone,
    dateStyle = if (date_style == "none") NULL else date_style,
    timeStyle = if (time_style == "none") NULL else time_style,
    more_date_options,
    locales_date_options
  )
  params <- dropNulls(params)
  structure(params, class = "dateFormatter")
}
