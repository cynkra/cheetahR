# Column formatter

Format numeric and date columns using international formatting
standards. Use `number_format()` to add data formatting to numeric
columns and `date_format()` to format date columns according to the
Intl.DateTimeFormat API.

## Usage

``` r
number_format(
  style = c("decimal", "currency", "percent", "unit"),
  currency = NULL,
  currency_display = c("symbol", "code", "narrowSymbol", "name"),
  currency_sign = c("standard", "accounting"),
  unit = NULL,
  unit_display = c("short", "narrow", "long"),
  locales = NULL,
  locale_options = NULL,
  digit_options = NULL,
  other_options = NULL
)

date_format(
  locales = NULL,
  day = c("numeric", "2-digit"),
  year = c("numeric", "2-digit"),
  hour = c("numeric", "2-digit"),
  minute = c("numeric", "2-digit"),
  second = c("numeric", "2-digit"),
  month = c("numeric", "2-digit", "long", "short", "narrow"),
  weekday = c("long", "short", "narrow"),
  day_period = c("narrow", "long", "short"),
  hour12 = FALSE,
  time_zone = NULL,
  date_style = c("none", "full", "long", "medium", "short"),
  time_style = c("none", "full", "long", "medium", "short"),
  more_date_options = NULL,
  locales_date_options = NULL
)
```

## Arguments

- style:

  The formatting style to use. Must be one of the following:

  - `"decimal"` for plain number formatting action columns. Default.

  - `"currency"` for currency formatting

  - `"percent"` for percent formatting.

  - `"unit"` for unit formatting.

- currency:

  The ISO 4217 currency code to use for currency formatting. Must be
  provided if `style` is `"currency"`.

- currency_display:

  The display format for the currency. Must be one of the following:

  - `"symbol"` for the currency symbol. Default. Use the localized
    currency symbol e.g. \$ for USD.

  - `"code"` for the currency code. Use the ISO 4217 currency code e.g.
    USD for US Dollar.

  - `"narrowSymbol"` for the narrow currency symbol. Use the narrow
    currency symbol e.g. `$100` instead of `$USD100`.

  - `"name"` for the currency name. Use the localized currency name e.g.
    Dollar for USD.

- currency_sign:

  The sign to use for the currency. Must be one of the following:

  - `"standard"` for the standard format. Default.

  - `"accounting"` for the accounting format. Use the accounting sign
    e.g. \$100 instead of \$USD100.

- unit:

  The unit to use for the unit formatting. Must be provided if `style`
  is `"unit"`.

- unit_display:

  The display format for the unit. Must be one of the following:

  - `"short"` for the short format. Default. E.g., 16 l

  - `"narrow"` for the narrow format. E.g., 16l

  - `"long"` for the long format. E.g., 16 liters

- locales:

  A character vector of BCP 47 language tags (e.g. `"en-US"` for
  English, `"ja-JP"` for Japanese) specifying the locales to use for
  formatting. If NULL, the runtime's default locale is used. See [BCP 47
  language
  tags](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/6c085406-a698-4e12-9d4d-c3b0ee3dbc4a)
  for reference.

- locale_options:

  A named list of options to customize the locale.

- digit_options:

  A named list of options to customize the digit.

- other_options:

  A named list of other options to customize the number formatting.

- day, month, year, hour, minute, second:

  The format to use for the day, month, year, hour, minute, and second.
  The possible values are `"numeric"`, and `"2-digit"` except month,
  with more options i.e `"long"`, `"short"`, and `"narrow"`. Default for
  all is `"numeric"`.

- weekday, day_period:

  The format to use for the weekday and day period. The possible values
  are `"long"`, `"short"`, and `"narrow"`.

- hour12:

  Whether to use 12-hour time format or the 24-hour format. Default is
  FALSE.

- time_zone:

  The time zone to use for the date formatting. E.g.
  `"America/New_York"`.

- date_style, time_style:

  The format to use for the date and time styles. The available values
  are `"none"`, `"full"`, `"long"`, `"medium"`, and `"short"`. Note:
  date_style and time_style can be used together, but not with other
  date-time component options like weekday, hour, or month.

- more_date_options:

  A named list of other options to customize the date formatting.

- locales_date_options:

  A named list of options to customize the locales for the date. @note
  Further details on customizing numeric formatting can be found in the
  [Intl.NumberFormat
  documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat/NumberFormat#parameters).
  Further details on customizing date formatting can be found in the
  [Intl.DateTimeFormat
  documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat/DateTimeFormat)

## Value

For `number_format()`: A list containing number formatting options that
can be used to format numeric data in a column. For `date_format()`: A
list containing date formatting options that can be used to format date
data in a column.

## Examples

``` r
# Number formatting examples
data <- data.frame(
  price_USD = c(125000.75, 299.99, 7890.45),
  price_EUR = c(410.25, 18750.60, 1589342.80),
  liter = c(20, 35, 42),
  percent = c(0.875, 0.642, 0.238)
)

cheetah(
  data,
  columns = list(
    price_USD = column_def(
      name = "USD",
      column_type = number_format(
        style = "currency",
        currency = "USD"
      )
    ),
    price_EUR = column_def(
      name = "EUR",
      column_type = number_format(
        style = "currency",
        currency = "EUR",
        locales = "de-DE"
      )
    ),
    liter = column_def(
      name = "Liter",
      column_type = number_format(
        style = "unit",
        unit = "liter",
        unit_display = "long"
      )
    ),
    percent = column_def(
      name = "Percent",
      column_type = number_format(style = "percent")
    )
  )
)
#> Warning: Could not parse locale in BCP 47 format; returning fallback 'en-US'
#> Warning: Could not parse locale in BCP 47 format; returning fallback 'en-US'
#> Warning: Could not parse locale in BCP 47 format; returning fallback 'en-US'

{"x":{"data":[{"price_USD":125000.75,"price_EUR":410.25,"liter":20,"percent":0.875},{"price_USD":299.99,"price_EUR":18750.6,"liter":35,"percent":0.642},{"price_USD":7890.45,"price_EUR":1589342.8,"liter":42,"percent":0.238}],"columns":[{"caption":"USD","width":"auto","columnType":{"style":"currency","currency":"USD","currencyDisplay":"symbol","currencySign":"standard","unitDisplay":"short","locales":"en-US","initializeNumFormat":true},"sort":false,"field":"price_USD"},{"caption":"EUR","width":"auto","columnType":{"style":"currency","currency":"EUR","currencyDisplay":"symbol","currencySign":"standard","unitDisplay":"short","locales":"de-DE","initializeNumFormat":true},"sort":false,"field":"price_EUR"},{"caption":"Liter","width":"auto","columnType":{"style":"unit","currencyDisplay":"symbol","currencySign":"standard","unit":"liter","unitDisplay":"long","locales":"en-US","initializeNumFormat":true},"sort":false,"field":"liter"},{"caption":"Percent","width":"auto","columnType":{"style":"percent","currencyDisplay":"symbol","currencySign":"standard","unitDisplay":"short","locales":"en-US","initializeNumFormat":true},"sort":false,"field":"percent"}],"search":"disabled","disableColumnResize":false,"allowRangePaste":false},"evals":[],"jsHooks":[]}
# Date formatting examples
date_data <- data.frame(
  date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03"))
)

cheetah(
  date_data,
  columns = list(
    date = column_def(
      name = "Date",
      column_type = date_format(
        locales = "en-US",
        day = "2-digit",
        month = "long",
        year = "numeric"
      )
    )
  )
)

{"x":{"data":[{"date":"2024-01-01"},{"date":"2024-01-02"},{"date":"2024-01-03"}],"columns":[{"caption":"Date","width":"auto","columnType":{"locales":"en-US","weekday":"long","day":"2-digit","month":"long","year":"numeric","hour":"numeric","minute":"numeric","second":"numeric","dayPeriod":"narrow","hour12":false,"initializeDateFormat":true},"sort":false,"field":"date"}],"search":"disabled","disableColumnResize":false,"allowRangePaste":false},"evals":[],"jsHooks":[]}
```
