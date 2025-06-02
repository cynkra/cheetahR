call_proxy_action <- function(proxy, method, args = list()) {
  if (!inherits(proxy, "cheetah_proxy")) {
    stop("proxy must be a cheetah_proxy object")
  }

  msg <- list(id = proxy$id, method = method, call = list(args = args))
  proxy$session$sendCustomMessage("cheetah-proxy-actions", msg)
  proxy
}

#' Cheetah Grid Proxy
#'
#' Creates a proxy object for a cheetah grid widget that can be used to modify the grid
#' without redrawing the entire widget.
#'
#' @param outputId The id of the cheetah table to create a proxy for.
#' @param session The Shiny session object. The default is to get the current session.
#'
#' @return A proxy object that can be used to modify the grid.
#'
#' @export
cheetah_proxy <- function(outputId, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("cheetah_proxy() can only be called from the server function of a Shiny app")
  }

  proxy <- list(
    id = session$ns(outputId),
    session = session
  )

  class(proxy) <- "cheetah_proxy"
  proxy
}

#' Add a row to a cheetah table
#'
#' Adds a new row to a cheetah grid widget without redrawing the entire widget.
#'
#' @param proxy A proxy object created by `cheetah_proxy()`.
#' @param data A single row dataframe for the new row in the table
#'
#' @export
add_row <- function(proxy, data) {
  stopifnot(
    "'data' must be of only one row" =
      is.data.frame(data) && nrow(data) == 1
  )

  data_json <- jsonlite::toJSON(data, dataframe = "rows")
  call_proxy_action(proxy, "addRow", list(data = data_json))
}



#' Delete a row from a cheetah grid
#'
#' Deletes a row from a cheetah grid widget without redrawing the entire widget.
#'
#' @param proxy A proxy object created by `cheetah_proxy()`.
#' @param row_index A numeric value representing the index of the row to delete.
#'
#' @export
delete_row <- function(proxy, row_index) {
  stopifnot("'row_index' must be a numeric value" =
              !is.null(row_index) && is.numeric(row_index)
            )

  # Reduce row index by 1 to fit index system in JS
  row_index <- row_index - 1
  call_proxy_action(proxy, "deleteRow", list(rowIndex = row_index))
}
