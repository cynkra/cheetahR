mtcars_bigdata <- do.call(rbind, rep(list(mtcars), 100000/nrow(mtcars)))
cheetah(mtcars_bigdata)
# DT::datatable(mtcars_bigdata, options = list(paging = FALSE))
reactable::reactable(mtcars_bigdata, pagination = FALSE)

microbenchmark::microbenchmark(
  cheetah(mtcars_bigdata),
  DT::datatable(mtcars_bigdata, options = list(paging = FALSE)),
  reactable::reactable(mtcars_bigdata),
  times = 1L
)

# TODO:
# Put it on cynkra github.
# With cheetah, check the time taken for 10,000 to 10,000,000 rows etc
# Also check with more columns. Say like 1,000 to 10,000 columns.
# Make it work for any type of data.


library(shiny)
library(bslib)

ui <- page_fluid(
  DT::DTOutput("table")
)

server <- function(input, output, session) {
  output$table <- renderDataTable({
    DT::datatable(mtcars_bigdata, options = list(paging = FALSE))
  })
}

shinyApp(ui, server)
