test_that("add_cell_message generates correct JS function", {
  get_js_text <- function(js_obj) {
    js_obj[1]
  }

  # Simple string message
  fn1 <- add_cell_message("warning", "Check this.")
  js1 <- get_js_text(fn1)
  expect_match(js1, "type: 'warning'")
  expect_match(js1, "message: 'Check this.'")

  # Test: raw JS expression
  raw_expr <- "rec.Species ? null : 'Please check.';"
  fn2 <- add_cell_message("error", raw_expr)
  js2 <- get_js_text(fn2)
  expect_match(js2, "type: 'error'")
  expect_true(grepl("message: rec.Species ? null : 'Please check.'", js2, , fixed = TRUE))

  # Test: info type and escaping quotes
  fn3 <- add_cell_message("info", "It's OK")
  js3 <- get_js_text(fn3)
  expect_match(js3, "type: 'info'")
  expect_match(js3, "message: 'It\\'s OK'")

  # Test: invalid type throws error
  expect_error(add_cell_message("critical", "Oops"),
               "'arg' should be one of")
})
