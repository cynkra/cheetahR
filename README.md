# cheetahR

cheetahR is an R package that brings the power of [Cheetah Grid](https://github.com/future-architect/cheetah-grid) to R. Designed for speed and efficiency, cheetahR will allow you to render millions of rows in just seconds, making it an excellent alternative to reactable and other R table widgets.

## Features

✅ Ultra-fast rendering of large datasets
✅ Lightweight and efficient memory usage
✅ Customizable styling and formatting
✅ Smooth scrolling and interaction
✅ Seamless integration with R and Shiny

## Installation (Coming soon)

Once available on CRAN or GitHub, you’ll be able to install it using:

``` r
# install.packages("pak")
# pak::pak("cynkra/cheetahR")

# Install from GitHub (once the package is ready)
# devtools::install_github("cynkra/cheetahR")

```

## Getting Started
So far, `cheetah()` is available to quick render a dataframe in R

```{r example}
library(cheetahR)

# Render table
cheetah(iris)

# Change some feature of some columns in the data
cheetah(
  iris,
  columns = list(
    Sepal.Length = column_def(name = "Sepal_Length"),
    Sepal.Width = column_def(name = "Sepal_Width", width = 100)
  )
)
```

## Shiny Integration
cheetahR will be fully compatible with Shiny, allowing for dynamic and interactive tables in web applications.

## Contributing
We welcome contributions! If you’d like to help improve cheetahR, feel free to submit issues, feature requests, or pull requests.

## Acknowledgments
This package is built on top of the amazing [Cheetah Grid](https://github.com/future-architect/cheetah-grid) JavaScript library.