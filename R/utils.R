is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

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

check_column_type <- function(x) {
  av_options <-
    c("text", "check", "number", "radio", "image", "multilinetext", "menu")

  if (!is.null(x) && !(x %in% av_options)) {
    msg <- sprintf(
      "Invalid `column_type`: '%s'.\n\nExpected one of the following options:\n  - %s",
      x,
      paste(av_options, collapse = "\n  - ")
    )
    stop(msg)
  }
}

update_col_list_with_classes <- function(data, col_list) {
  col_classes <- lapply(data, class)
  in_shiny <- shiny::isRunning()
  is_testing <- is_testing()

  for (col_name in names(col_classes)) {
    if (is.null(col_list[[col_name]]$columnType)) {
      if (col_classes[[col_name]] %in% c("numeric", "integer")) {
        col_list[[col_name]]$columnType <- "number"
      } else if (
        col_classes[[col_name]] == "factor" && any(in_shiny, is_testing)
      ) {
        # This is to recover the possible choices for a factor column.
        menu_opt <- lapply(
          unique(data[[col_name]]),
          \(val) {
            list(value = val, label = val)
          }
        )
        col_list[[col_name]]$columnType <- "menu"
        col_list[[col_name]]$action <-
          list(type = "inline_menu", options = menu_opt)
      } else {
        col_list[[col_name]]$columnType <- "text"
      }
    }
  }

  col_list
}

check_action_type <- function(action = NULL, column_type = NULL) {
  if (is.null(action)) return(invisible())

  valid_actions <- c("input", "check", "radio", "inline_menu")
  if (!action %in% valid_actions) {
    stop(
      "Invalid action type. Must be one of: ",
      paste(valid_actions, collapse = ", ")
    )
  }

  # Validate action-column type compatibility
  if (
    action == "inline_menu" && any(is.null(column_type), column_type != "menu")
  ) {
    stop("'inline_menu' action can only be used with 'menu' column type")
  }
}

make_table_sortable <- function(columns, sortable = TRUE) {
  if (!sortable) {
    return(columns)
  } else {
    for (col_name in names(columns)) {
      if (is.null(columns[[col_name]]$sort)) {
        columns[[col_name]]$sort <- TRUE
      }
    }
  }
  columns
}

`%notin%` <- Negate('%in%')

