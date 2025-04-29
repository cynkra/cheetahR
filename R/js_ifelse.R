#' Convert an R-style conditional to a JS ternary expression
#'
#' @param condition An R expression (logical) using \%in\%, \%notin\% or grepl(), etc.
#' @param true_result A string value to return when the condition is TRUE.
#' @param false_result A string value to return when the condition is FALSE.
#' @return A character string containing a JavaScript ternary expression.
#' @export
js_ifelse <- function(condition, true_result, false_result) {
  # Capture the unevaluated expression and convert it to string
  condition <- substitute(condition)
  condition <- paste(deparse(condition), collapse = " ")

  # Handle %in% and %notin%
  handle_in_operators <- function(text) {
    pattern <- "(\\b[[:alnum:]_]+)\\s*%(not)?in%\\s*c\\(([^\\)]+)\\)"
    matches <- gregexpr(pattern, text, perl = TRUE)[[1]]
    if (matches[1] == -1) return(text)

    regmatches_list <- regmatches(text, gregexpr(pattern, text, perl = TRUE))

    for (match in regmatches_list[[1]]) {
      var <- sub("^([[:alnum:]_]+).*", "\\1", match)
      is_negated <- grepl("%notin%", match)
      values <- sub(".*%not?in%\\s*c\\(([^\\)]+)\\)", "\\1", match)
      values_vec <- trimws(gsub("\"|'", "", unlist(strsplit(values, ","))))
      js_array <- paste0("[", paste0("'", values_vec, "'", collapse = ", "), "]")
      js_expr <- paste0(js_array, ".includes(rec.", var, ")")
      if (is_negated) js_expr <- paste0("!", js_expr)
      text <- sub(pattern, js_expr, text, perl = TRUE)
    }

    text
  }

  # Handle grepl() expressions
  handle_grepl <- function(text) {
    pattern <- "(!?\\s*)grepl\\((['\"].+?['\"]),\\s*([[:alnum:]_]+)\\)"
    matches <- gregexpr(pattern, text, perl = TRUE)[[1]]
    if (matches[1] == -1) return(text)

    regmatches_list <- regmatches(text, gregexpr(pattern, text, perl = TRUE))

    for (match in regmatches_list[[1]]) {
      not_prefix <- ifelse(grepl("^!", match), "!", "")
      regex <- sub(".*grepl\\((['\"].+?['\"]).*", "\\1", match)
      var <- sub(".*grepl\\(.*?,\\s*([[:alnum:]_]+)\\)", "\\1", match)
      regex <- gsub("^['\"]|['\"]$", "", regex)  # Remove quotes
      js_expr <- paste0(not_prefix, "/", regex, "/.test(rec.", var, ")")
      text <- sub(pattern, js_expr, text, perl = TRUE)
    }

    text
  }

  condition <- condition |> handle_in_operators() |> handle_grepl()

  # Replace R logical operators with JS equivalents
  js_condition <- condition
  js_condition <- gsub("&&", "&&", js_condition)
  js_condition <- gsub("&", "&&", js_condition)
  js_condition <- gsub("\\|\\|", "||", js_condition)
  js_condition <- gsub("\\|", "||", js_condition)
  js_condition <- gsub("==", "===", js_condition)
  js_condition <- gsub("!=", "!==", js_condition)

  # Prefix variables with rec., skipping those already prefixed or in JS calls
  js_condition <- gsub(
    "(?<![\\.'\"\\]\\w])\\b([A-Za-z_][A-Za-z0-9_]*)\\b",
    "rec.\\1",
    js_condition,
    perl = TRUE
  )

  # Format return values
  format_js_value <- function(x) {
    if (x == "") "null" else paste0("'", x, "'")
  }

  true_val <- format_js_value(true_result)
  false_val <- format_js_value(false_result)

  # Assemble JS ternary expression
  paste0(js_condition, " ? ", true_val, " : ", false_val, ";")
}

