test_that("test utils", {

  expect_type(column_def(name = "Sepal_Length"), "list")

  expect_named(
    column_def(name = "Sepal_Length"),
    c("caption", "width", "minWidth",
      "maxWidth", "columnType", "action",
      "style")
  )
})

test_that("test column style check", {

  columns <- list(
    Sepal.Length = column_def(name = "Sepal_Length"),
    Species = column_def(style = "red")
  )

  expect_error(column_style_check(columns), "The style attribute expects a list")
})

