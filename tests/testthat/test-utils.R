test_that("test column defintion", {
  expect_type(column_def(name = "Sepal_Length"), "list")

  expect_named(
    column_def(name = "Sepal_Length"),
    c(
      "caption",
      "width",
      "minWidth",
      "maxWidth",
      "columnType",
      "action",
      "style",
      "message",
      "sort"
    )
  )

  expect_snapshot(
    error = TRUE,
    {
      # Message must be wrapped by JS
      column_def(message = "test")
    }
  )
})

test_that("test column group", {
  expect_type(
    column_group(
      name = "Sepal",
      columns = c("Sepal.Length", "Sepal.Width")
    ),
    "list"
  )

  expect_named(
    column_group(
      name = "Sepal",
      columns = c("Sepal.Length", "Sepal.Width")
    ),
    c(
      "caption",
      "columns"
    )
  )

  expect_error(
    column_group(name = "Sepal"),
    'argument "columns" is missing, with no default'
  )
})

test_that("test column style check", {
  columns <- list(
    Sepal.Length = column_def(name = "Sepal_Length"),
    Species = column_def(style = "red")
  )

  expect_error(
    column_style_check(columns),
    "The style attribute expects a list"
  )
})

test_that("update_col_list_with_classes sets columnType correctly", {
  data <- data.frame(
    full_name = c("Anne Smith", "Mike John", "John Doe", "Janet Jones"),
    grade = c(78, 52, 3, 27),
    passed = c(TRUE, TRUE, FALSE, FALSE),
    gender = c("female", "male", "male", "female")
  )

  # Set 'gender' to a factor column
  data$gender <- as.factor(data$gender)

  columns <- list(
    passed = list(columnType = "check"),
    full_name = list(name = "Names")
  )

  updated_col_list <- update_col_list_with_classes(data, columns)

  # Column 'grade' is numeric, columnType becomes "number"
  expect_equal(updated_col_list$grade$columnType, "number")

  # Column 'passed' is set, so the columnType remains unchanged
  expect_equal(updated_col_list$passed$columnType, "check")

  # Column 'full_name' is (non-numeric), columnType becomes "text"
  expect_equal(updated_col_list$full_name$columnType, "text")

  # Column 'gender' is a factor, columnType becomes "menu" and action to "inline_menu"
  expect_equal(updated_col_list$gender$columnType, "menu")
  expect_equal(updated_col_list$gender$action$type, "inline_menu")
})
