test_that("test utils", {

  expect_type(column_def(name = "Sepal_Length"), "list")

  expect_named(
    column_def(name = "Sepal_Length"),
    c("caption", "width", "minWidth", "maxWidth", "columnType", "action")
  )
})
