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

convert_row_column <- function(data) {
  tibble::rownames_to_column(data, "_row")
}
