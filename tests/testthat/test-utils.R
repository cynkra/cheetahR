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


test_that("number_format() creates a numFormat S3 object with correct fields", {
  fmt <- number_format(
    locales = "ja-JP",
    style = "currency",
    currency = "JPY"
  )
  expect_s3_class(fmt, "numFormat")
  expect_equal(fmt$locales, "ja-JP")
  expect_equal(fmt$style, "currency")
  expect_equal(fmt$currency, "JPY")

  # Throws error for invalid input
  expect_error(number_format(locales = 123), "character")
})

test_that("date_format() creates a dateFormatter S3 object with correct fields", {
  # Test basic date formatting
  fmt <- date_format(
    locales = "en-US",
    month = "long",
    day = "numeric",
    year = "numeric"
  )
  expect_s3_class(fmt, "dateFormatter")
  expect_equal(fmt$locales, "en-US")
  expect_equal(fmt$month, "long")
  expect_equal(fmt$day, "numeric")
  expect_equal(fmt$year, "numeric")

  # Test with date/time styles
  fmt2 <- date_format(
    locales = "de-DE",
    date_style = "full",
    time_style = "medium"
  )
  expect_s3_class(fmt2, "dateFormatter")
  expect_equal(fmt2$dateStyle, "full")
  expect_equal(fmt2$timeStyle, "medium")
  expect_null(fmt2$month) # Should be NULL when styles are used

  # Test error handling
  expect_error(date_format(hour12 = "yes"), "logical")
  expect_error(date_format(locales_date_options = "not_a_list"), "named list")
})
