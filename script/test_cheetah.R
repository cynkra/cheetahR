cheetah(
  head(iris),
  columns = list(
    Sepal.Length = column_def(name = "Sepal_Length"),
    Species = column_def(width = 50, style = list(textOverflow = "ellipsis"))
  )
)

cheetah(
  mtcars,
  columns = list(
    mpg = column_def(name = "MPG"),
    cyl = column_def(name = "Cylinder", width = 100),
    rownames = column_def(width = 50, style = list(color = "red"))
  )
)

