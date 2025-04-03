is_named_list <- function(x) {
  is.list(x) && !is.null(names(x)) && all(names(x) != "")
}

lgl_ply <- function(x, fun, ..., length = 1L, use_names = FALSE) {
  vapply(x, fun, logical(length), ..., USE.NAMES = use_names)
}

dropNulls <- function(x) {
  x[!lgl_ply(x, is.null)]
}

add_field_to_list <- function(x) {
  lapply(names(x), function(i) {
    x[[i]]$field <- i
    dropNulls((x[[i]]))
  })
}

column_style_check <- function(columns) {
  lapply(columns, function(x) {
    if ("style" %in% names(x) && !is.null(x$style)) {
      stopifnot(
        "The style attribute expects a list" = is.list(x$style) &&
          !is.null(names(x$style))
      )
    }
  })
  invisible()
}

process_rownames <- function(data, columns, rownames = TRUE) {
  has_char_rownames <- is.character(attr(data, "row.names"))

  data <-
    if (rownames && has_char_rownames) {
      rowname_var <- if ("rownames" %in% names(columns)) {
        if (is.null(columns$rownames$caption)) {
          columns$rownames$caption <- " "
        }
        "rownames"
      } else {
        " "
      }

      tibble::rownames_to_column(data, var = rowname_var)
    } else if (has_char_rownames) {
      tibble::rownames_to_column(data)[-1]
    } else {
      data
    }
  list(data = data, columns = columns)
}
