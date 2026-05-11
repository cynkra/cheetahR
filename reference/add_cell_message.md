# Create a JavaScript cell message function for cheetahR widgets

Generates a JS function (wrapped with
[`htmlwidgets::JS`](https://rdrr.io/pkg/htmlwidgets/man/JS.html)) that,
given a record (`rec`), returns an object with `type` and `message`.

## Usage

``` r
add_cell_message(type = c("error", "warning", "info"), message = "message")
```

## Arguments

- type:

  A string that specifies the type of message. One of `"error"`,
  `"warning"`, or `"info"`. Default is `"error"`.

- message:

  A string or JS expression. If it contains `rec.`, `?`, `:`, or a
  trailing `;`, it is treated as raw JS (no additional quoting).
  Otherwise, it is escaped and wrapped in single quotes.

## Value

A [`htmlwidgets::JS`](https://rdrr.io/pkg/htmlwidgets/man/JS.html)
object containing a JavaScript function definition:

    function(rec) {
      return {
        type: "<type>",
        message: <message>
      };
    }

Use this within [`column_def()`](column_def.md) for cell validation

## Examples

``` r
set.seed(123)
iris_rows <- sample(nrow(iris), 10)
data <- iris[iris_rows, ]

# Simple warning
cheetah(
  data,
  columns = list(
    Species = column_def(
      message = add_cell_message(type = "info", message = "Ok")
    )
  )
)

{"x":{"data":[{"Sepal.Length":4.3,"Sepal.Width":3,"Petal.Length":1.1,"Petal.Width":0.1,"Species":"setosa"},{"Sepal.Length":5,"Sepal.Width":3.3,"Petal.Length":1.4,"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":7.7,"Sepal.Width":3.8,"Petal.Length":6.7,"Petal.Width":2.2,"Species":"virginica"},{"Sepal.Length":4.4,"Sepal.Width":3.2,"Petal.Length":1.3,"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":5.9,"Sepal.Width":3,"Petal.Length":5.1,"Petal.Width":1.8,"Species":"virginica"},{"Sepal.Length":6.5,"Sepal.Width":3,"Petal.Length":5.2,"Petal.Width":2,"Species":"virginica"},{"Sepal.Length":5.5,"Sepal.Width":2.5,"Petal.Length":4,"Petal.Width":1.3,"Species":"versicolor"},{"Sepal.Length":5.5,"Sepal.Width":2.6,"Petal.Length":4.4,"Petal.Width":1.2,"Species":"versicolor"},{"Sepal.Length":5.8,"Sepal.Width":2.7,"Petal.Length":5.1,"Petal.Width":1.9,"Species":"virginica"},{"Sepal.Length":6.1,"Sepal.Width":3,"Petal.Length":4.6,"Petal.Width":1.4,"Species":"versicolor"}],"columns":[{"width":"auto","columnType":"text","message":"function(rec) {\n  return {\n    type: 'info',\n    message: 'Ok'\n  };\n}","sort":false,"field":"Species"},{"columnType":"number","sort":true,"width":"auto","field":"Sepal.Length"},{"columnType":"number","sort":true,"width":"auto","field":"Sepal.Width"},{"columnType":"number","sort":true,"width":"auto","field":"Petal.Length"},{"columnType":"number","sort":true,"width":"auto","field":"Petal.Width"}],"search":"disabled","disableColumnResize":false,"allowRangePaste":false},"evals":["columns.0.message"],"jsHooks":[]}
# Conditional error using `js_ifelse()`
cheetah(
  data,
  columns = list(
    Species = column_def(
      message = add_cell_message(
        message = js_ifelse(Species == "setosa", "", "Invalid")
      )
    )
  )
)

{"x":{"data":[{"Sepal.Length":4.3,"Sepal.Width":3,"Petal.Length":1.1,"Petal.Width":0.1,"Species":"setosa"},{"Sepal.Length":5,"Sepal.Width":3.3,"Petal.Length":1.4,"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":7.7,"Sepal.Width":3.8,"Petal.Length":6.7,"Petal.Width":2.2,"Species":"virginica"},{"Sepal.Length":4.4,"Sepal.Width":3.2,"Petal.Length":1.3,"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":5.9,"Sepal.Width":3,"Petal.Length":5.1,"Petal.Width":1.8,"Species":"virginica"},{"Sepal.Length":6.5,"Sepal.Width":3,"Petal.Length":5.2,"Petal.Width":2,"Species":"virginica"},{"Sepal.Length":5.5,"Sepal.Width":2.5,"Petal.Length":4,"Petal.Width":1.3,"Species":"versicolor"},{"Sepal.Length":5.5,"Sepal.Width":2.6,"Petal.Length":4.4,"Petal.Width":1.2,"Species":"versicolor"},{"Sepal.Length":5.8,"Sepal.Width":2.7,"Petal.Length":5.1,"Petal.Width":1.9,"Species":"virginica"},{"Sepal.Length":6.1,"Sepal.Width":3,"Petal.Length":4.6,"Petal.Width":1.4,"Species":"versicolor"}],"columns":[{"width":"auto","columnType":"text","message":"function(rec) {\n  return {\n    type: 'error',\n    message: rec['Species'] === 'setosa' ? null : 'Invalid'\n  };\n}","sort":false,"field":"Species"},{"columnType":"number","sort":true,"width":"auto","field":"Sepal.Length"},{"columnType":"number","sort":true,"width":"auto","field":"Sepal.Width"},{"columnType":"number","sort":true,"width":"auto","field":"Petal.Length"},{"columnType":"number","sort":true,"width":"auto","field":"Petal.Width"}],"search":"disabled","disableColumnResize":false,"allowRangePaste":false},"evals":["columns.0.message"],"jsHooks":[]}
# Directly using a JS expression as string
cheetah(
  data,
  columns = list(
    Sepal.Width = column_def(
      style = list(textAlign = "left"),
      message = add_cell_message(
        type = "warning",
        message = "rec['Sepal.Width'] <= 3 ? 'NarrowSepal' : 'WideSepal';"
      )
    )
  )
)

{"x":{"data":[{"Sepal.Length":4.3,"Sepal.Width":3,"Petal.Length":1.1,"Petal.Width":0.1,"Species":"setosa"},{"Sepal.Length":5,"Sepal.Width":3.3,"Petal.Length":1.4,"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":7.7,"Sepal.Width":3.8,"Petal.Length":6.7,"Petal.Width":2.2,"Species":"virginica"},{"Sepal.Length":4.4,"Sepal.Width":3.2,"Petal.Length":1.3,"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":5.9,"Sepal.Width":3,"Petal.Length":5.1,"Petal.Width":1.8,"Species":"virginica"},{"Sepal.Length":6.5,"Sepal.Width":3,"Petal.Length":5.2,"Petal.Width":2,"Species":"virginica"},{"Sepal.Length":5.5,"Sepal.Width":2.5,"Petal.Length":4,"Petal.Width":1.3,"Species":"versicolor"},{"Sepal.Length":5.5,"Sepal.Width":2.6,"Petal.Length":4.4,"Petal.Width":1.2,"Species":"versicolor"},{"Sepal.Length":5.8,"Sepal.Width":2.7,"Petal.Length":5.1,"Petal.Width":1.9,"Species":"virginica"},{"Sepal.Length":6.1,"Sepal.Width":3,"Petal.Length":4.6,"Petal.Width":1.4,"Species":"versicolor"}],"columns":[{"width":"auto","columnType":"number","style":{"textAlign":"left"},"message":"function(rec) {\n  return {\n    type: 'warning',\n    message: rec['Sepal.Width'] <= 3 ? 'NarrowSepal' : 'WideSepal'\n  };\n}","sort":false,"field":"Sepal.Width"},{"columnType":"number","sort":true,"width":"auto","field":"Sepal.Length"},{"columnType":"number","sort":true,"width":"auto","field":"Petal.Length"},{"columnType":"number","sort":true,"width":"auto","field":"Petal.Width"},{"columnType":"text","sort":true,"width":"auto","field":"Species"}],"search":"disabled","disableColumnResize":false,"allowRangePaste":false},"evals":["columns.0.message"],"jsHooks":[]}
```
