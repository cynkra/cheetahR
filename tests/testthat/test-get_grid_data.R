# Test get_grid_data() (Shiny reactive data state)
# We test by passing a mock session with input$<id>_data_state set,
# simulating what the JS sends when the grid is edited.

# Mock session: list with input list (same shape as Shiny session for our use)
mock_session <- function(grid_data_state) {
  list(input = list(grid_data_state = grid_data_state))
}

test_that("get_grid_data() returns NULL when grid_data_state is not set", {
  session <- list(input = list())
  out <- get_grid_data("grid", session = session)
  expect_null(out)
})

test_that("get_grid_data() returns data frame when grid_data_state is set", {
  # Column-wise data as sent by the JS (arrayToList)
  grid_data_state <- list(
    mpg = c(21, 21, 22.8),
    cyl = c(6, 6, 4),
    disp = c(160, 160, 108)
  )
  session <- mock_session(grid_data_state)

  out <- get_grid_data("grid", session = session)
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 3L)
  expect_equal(names(out), c("mpg", "cyl", "disp"))
  expect_equal(out$mpg, c(21, 21, 22.8))
})

test_that("get_grid_data() with handle_rownames = TRUE uses first column as row names", {
  grid_data_state <- list(
    id = c("a", "b", "c"),
    x = c(1, 2, 3),
    y = c(4, 5, 6)
  )
  session <- mock_session(grid_data_state)

  out <- get_grid_data("grid", session = session, handle_rownames = TRUE)
  expect_s3_class(out, "data.frame")
  expect_equal(rownames(out), c("a", "b", "c"))
  expect_equal(names(out), c("x", "y"))
})

test_that("get_grid_data() with handle_rownames = 'colname' uses that column as row names", {
  grid_data_state <- list(
    x = c(1, 2, 3),
    label = c("A", "B", "C"),
    y = c(4, 5, 6)
  )
  session <- mock_session(grid_data_state)

  out <- get_grid_data("grid", session = session, handle_rownames = "label")
  expect_s3_class(out, "data.frame")
  expect_equal(rownames(out), c("A", "B", "C"))
  expect_equal(names(out), c("x", "y"))
})

test_that("get_grid_data() with handle_rownames = FALSE keeps all columns", {
  grid_data_state <- list(
    id = c("a", "b"),
    value = c(10, 20)
  )
  session <- mock_session(grid_data_state)

  out <- get_grid_data("grid", session = session, handle_rownames = FALSE)
  expect_s3_class(out, "data.frame")
  expect_equal(names(out), c("id", "value"))
  expect_equal(out$id, c("a", "b"))
})
