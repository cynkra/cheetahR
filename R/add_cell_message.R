#' Create a JavaScript cell message function for cheetahR widgets
#'
#' Generates a JS function (wrapped with `htmlwidgets::JS`) that,
#' given a record (`rec`), returns an object with `type` and `message`.
#'
#' @param type A string that specifies the type of message.
#' One of `"error"`, `"warning"`, or `"info"`. Default is `"error"`.
#' @param message A string or JS expression. If it contains `rec.`, `?`, `:`,
#' or a trailing `;`, it is treated as raw JS (no additional quoting).
#' Otherwise, it is escaped and wrapped in single quotes.
#'
#' @return A `htmlwidgets::JS` object containing a JavaScript function definition:
#'```js
#' function(rec) {
#'   return {
#'     type: "<type>",
#'     message: <message>
#'   };
#' }
#'```
#' Use this within `column_def()` for cell validation
#'
#' @examples
#' set.seed(123)
#' iris_rows <- sample(nrow(iris), 10)
#' data <- iris[iris_rows, ]
#'
#' # Simple warning
#' cheetah(
#'   data,
#'   columns = list(
#'     Species = column_def(
#'       message = add_cell_message(type = "info", message = "Ok")
#'     )
#'   )
#' )
#'
#' # Conditional error using `js_ifelse()`
#' cheetah(
#'   data,
#'   columns = list(
#'     Species = column_def(
#'       message = add_cell_message(
#'         message = js_ifelse(Species == "setosa", "", "Invalid")
#'       )
#'     )
#'   )
#' )
#'
#' # Directly using a JS expression as string
#' cheetah(
#'   data,
#'   columns = list(
#'     Sepal.Width = column_def(
#'       style = list(textAlign = "left"),
#'       message = add_cell_message(
#'         type = "warning",
#'         message = "rec['Sepal.Width'] <= 3 ? 'NarrowSepal' : 'WideSepal';"
#'       )
#'     )
#'   )
#' )
#'
#' @export
add_cell_message <- function(
  type = c("error", "warning", "info"),
  message = "message"
) {
  type <- match.arg(type)

  is_js_expr <- grepl("rec\\.|\\?|\\:|;$", message)
  js_msg <- if (is_js_expr) {
    sub(";$", "", message)
  } else {
    msg_esc <- gsub("'", "\\'", message)
    paste0("'", msg_esc, "'")
  }

  js_fn <- paste0(
    "function(rec) {\n",
    "  return {\n",
    "    type: '",
    type,
    "',\n",
    "    message: ",
    js_msg,
    "\n",
    "  };\n",
    "}"
  )

  htmlwidgets::JS(js_fn)
}
