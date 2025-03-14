# cheetahR

cheetahR is an R package that brings the power of [Cheetah Grid](https://github.com/future-architect/cheetah-grid) to R. Designed for speed and efficiency, cheetahR will allow you to render millions of rows in just a few milliseconds, making it an excellent alternative to reactable and other R table widgets. The goal of cheetahR is to wrap the JavaScript functions of Cheetah Grid and make them readily available for R users, providing a seamless and high-performance table widget for R applications.

## Features

- Ultra-fast rendering of large datasets
- Lightweight and efficient memory usage
- Customizable styling and formatting
- Smooth scrolling and interaction
- Seamless integration with R and Shiny

## Installation (Coming soon)

Once available on CRAN or GitHub, you’ll be able to install it using:

``` r
# install.packages("pak")
# pak::pak("cynkra/cheetahR")

# Install from GitHub (once the package is ready)
# devtools::install_github("cynkra/cheetahR")

```

## Getting Started
So far, `cheetah()` is available to render a dataframe in R

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

## API Integration
cheetahR is compatible with Shiny, allowing for dynamic and interactive tables in web applications. Although still a work in progress.

## Contributing
We welcome contributions! If you’d like to help improve cheetahR, feel free to submit issues, feature requests, or pull requests.

### Software Pre-requiste
To contribute to this project, some software installations are required, such as `npm`, `node`, and `packer`. Please follow the slides attached to help you get started [pre-requisites](https://rsc.cynkra.com/js4Shiny/#/software-pre-requisites). Click here to install [packer](https://rsc.cynkra.com/js4Shiny/#/solutions). 

When you are in the project, do the following:
```{r} 
packer::npm_install()
# Change the code and then rebundle
packer::bundle("development") # For developement mode
packer::bundle() # For production. Defaut!
```
You may as well bundle for `dev` using `packer::bundle_dev()` when in developer mode and when ready for production use `packer::bundle_prod()`. You may also consider `watch()` which watches for changes in the `srcjs` and rebuilds if necessary, equivalent to `⁠npm run watch⁠`.

## Acknowledgments
This package is built on top of the amazing [Cheetah Grid](https://github.com/future-architect/cheetah-grid) JavaScript library.
