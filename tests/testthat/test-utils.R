test_that("test utils", {
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
      "style"
    )
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
    full_name = c("Alan Smith", "Mike John", "John Doe"),
    grade = c(78, 52, 3),
    passed = c(TRUE, FALSE, TRUE)
  )

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
})
