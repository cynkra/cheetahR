test_that("test cheetah", {

  server <- function(input, output, session) {
    output$grid <- rendercheetah({
      cheetah(data = head(iris))
    })
  }

  shiny::testServer(server, {
    expect_s3_class(session$getOutput("grid"), "json")
  })
})
