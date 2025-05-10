test_that("cheetah handles rownames correctly", {
  # Test with default rowname behavior (TRUE)
  widget <- cheetah(swiss)
  expect_s3_class(widget, "htmlwidget")
  expect_s3_class(widget, "cheetah")

  # Test with rownames explicitly set to TRUE
  widget_explicit <- cheetah(swiss, rownames = TRUE)
  expect_s3_class(widget_explicit, "htmlwidget")
  expect_s3_class(widget_explicit, "cheetah")

  # Test with rownames disabled
  widget_no_row <- cheetah(swiss, rownames = FALSE)
  expect_s3_class(widget_no_row, "htmlwidget")
  expect_s3_class(widget_no_row, "cheetah")

  # Test with iris (numeric rownames should not be shown)
  widget_iris <- cheetah(iris)
  expect_s3_class(widget_iris, "htmlwidget")
  expect_s3_class(widget_iris, "cheetah")
})

test_that("test cheetah", {
  server <- function(input, output, session) {
    output$grid <- renderCheetah({
      cheetah(data = head(iris))
    })
  }

  shiny::testServer(server, {
    expect_s3_class(session$getOutput("grid"), "json")
  })

  expect_snapshot(error = TRUE, {
    cheetah(iris, search = "plop")
  })
})
