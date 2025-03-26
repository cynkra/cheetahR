test_that("cheetah handles rownames correctly", {
  # Test with default rowname behavior (TRUE)
  widget <- cheetah(swiss)
  expect_s3_class(widget, "htmlwidget")
  expect_s3_class(widget, "cheetah")

  cheetah(mtcars)
  
  # Test with custom rowname column name
  widget_custom <- cheetah(swiss, rowname = "Canton")
  expect_s3_class(widget_custom, "htmlwidget")
  expect_s3_class(widget_custom, "cheetah")
  
  # Test with rowname column customization
  widget_custom_col <- cheetah(swiss, 
    columns = list(
      `_row` = column_def(name = "Swiss Canton", text_align = "left")
    )
  )
  expect_s3_class(widget_custom_col, "htmlwidget")
  expect_s3_class(widget_custom_col, "cheetah")
  
  # Test with rownames disabled
  widget_no_row <- cheetah(swiss, rowname = FALSE)
  expect_s3_class(widget_no_row, "htmlwidget")
  expect_s3_class(widget_no_row, "cheetah")
}) 