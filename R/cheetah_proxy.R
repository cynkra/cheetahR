call_proxy_action <- function(proxy, method, args = list()) {
  if (!inherits(proxy, "cheetahProxy")) {
    stop("proxy must be a cheetahProxy object")
  }

  msg <- list(id = proxy$id, call = list(method = method, args = args))

  sess <- proxy$session
  sess$sendCustomMessage("cheetah-proxy-actions", msg)

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
    stop("cheetahProxy must be called from the server function of a Shiny app")
  }

  proxy <-
    list(
      id = session$ns(outputId),
      rawId = outputId,
      session = session
    )

  class(proxy) <- "cheetahProxy"

  proxy
}


#' Update the data in a cheetah grid
#'
#' Updates the data in a cheetah grid widget without redrawing the entire widget.
#'
#' @param proxy A proxy object created by `cheetahProxy()`.
#' @param data The new data to display in the grid.
#'
#' @export
updateCheetahData <- function(proxy, data) {
  stopifnot("'data' must be a dataframe" = is.data.frame(data))

  data_json <- jsonlite::toJSON(data, dataframe = "rows")
  call_proxy_action(proxy, "addRow", list(
    id = proxy$id,
    data = data_json
  ))
}

#' Add a row to a cheetah table
#'
#' Adds a new row to a cheetah grid widget without redrawing the entire widget.
#'
#' @param proxy A proxy object created by `cheetahProxy()`.
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


#' Update a row in a cheetah grid
#'
#' Updates an existing row in a cheetah grid widget without redrawing the entire widget.
#'
#' @param proxy A proxy object created by `cheetahProxy()`.
#' @param row_index A numeric value representing the index of the row to update.
#' @param data A single row dataframe to update the row.
#'
#' @export
update_row <- function(proxy, row_index, data) {
  stopifnot("'row_index' must be numeric" = is.numeric(row_index))
  stopifnot(
    "'data' must be of only one row" =
      is.data.frame(data) && nrow(data) == 1
  )

  data_json <- jsonlite::toJSON(data, dataframe = "rows")
  call_proxy_action(proxy, "updateRow", list(
    rowIndex = row_index,
    data = data_json
  ))
}

#' Delete a row from a cheetah grid
#'
#' Deletes a row from a cheetah grid widget without redrawing the entire widget.
#'
#' @param proxy A proxy object created by `cheetahProxy()`.
#' @param row_index A numeric value representing the index of the row to delete.
#'
#' @export
delete_row <- function(proxy, row_index) {
  stopifnot("'row_index' must be numeric" = is.numeric(row_index))
  call_proxy_action(proxy, "delete_row", list(
    id = proxy$id,
    rowIndex = row_index
  ))
}
