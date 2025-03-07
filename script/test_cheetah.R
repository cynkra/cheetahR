cheetah(
  convert_row_column(iris),
  columns = list(
    Sepal.Length = column_def(name = "Sepal_Length"),
    Sepal.Width = column_def(name = "Sepal_Width", width = 50),
    `_row` = column_def(column_type = "check", action = "check")
  )
)

cheetah(
  convert_row_column(mtcars),
  columns = list(
    mpg = column_def(name = "MPG"),
    cyl = column_def(name = "Cylinder", width = 100),
    `_row` = column_def(column_type = "check", action = "check")
  )
)

# TODO:
# Open issues with these on github for dev day
# How to manage data with too long characters?
# Make the cheetahR more like reactable
# Nice to investigate: Available events and how to pass it to shiny for updates
