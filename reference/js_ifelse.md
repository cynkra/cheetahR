# Convert an R logical expression into a JS ternary expression

Convert an R logical expression into a JS ternary expression

## Usage

``` r
js_ifelse(condition, if_true = "", if_false = "")
```

## Arguments

- condition:

  An R logical expression (supports %in% / %notin% / grepl() /
  comparisons / & \|)

- if_true:

  String to return when the condition is TRUE. Default is an empty
  string, which interprets as `null` in JS.

- if_false:

  String to return when the condition is FALSE. Default is an empty
  string, which interprets as `null` in JS.

## Value

A single character string containing a JavaScript ternary expression.
