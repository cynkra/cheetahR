test_that("js_ifelse conversion", {
  # Simple logic: numeric comparisons and equality
  expect_equal(
    js_ifelse(Sepal.Length > 5, "BigSepal", ""),
    "rec['Sepal.Length'] > 5 ? 'BigSepal' : null;"
  )
  expect_equal(
    js_ifelse(Species == "setosa", "IsSetosa", ""),
    "rec['Species'] === 'setosa' ? 'IsSetosa' : null;"
  )
  expect_equal(
    js_ifelse(Sepal.Width <= 3, "NarrowSepal", "WideSepal"),
    "rec['Sepal.Width'] <= 3 ? 'NarrowSepal' : 'WideSepal';"
  )

  # Combined logic
  expr <- js_ifelse(Sepal.Length > 5 & Species %notin% c("setosa"), "E", "X")
  expect_true(grepl("rec['Sepal.Length'] > 5 && !['setosa'].includes", expr, fixed = TRUE))

  # Truthiness of bare variable
  expect_equal(
    js_ifelse(Species, "", "Please check."),
    "rec['Species'] ? null : 'Please check.';"
  )

  # Basic %in%  and  %notin%
  expect_equal(
    js_ifelse(Species %in% c("setosa", "virginica"), "Bad", ""),
    "['setosa','virginica'].includes(rec['Species']) ? 'Bad' : null;"
  )
  expect_equal(
    js_ifelse(Species %notin% c("setosa"), "OK", ""),
    "!['setosa'].includes(rec['Species']) ? 'OK' : null;"
  )

  # grepl() and !grepl()
  expect_equal(
    js_ifelse(grepl("^vir", Species), "Yes", ""),
    "/^vir/.test(rec['Species']) ? 'Yes' : null;"
  )
  expect_equal(
    js_ifelse(!grepl("set", Species), "NoSet", ""),
    "!/set/.test(rec['Species']) ? 'NoSet' : null;"
  )
})
