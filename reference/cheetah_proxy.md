# Cheetah Grid Proxy

Creates a proxy object for a cheetah grid widget that can be used to
modify the grid without redrawing the entire widget.

## Usage

``` r
cheetah_proxy(outputId, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- outputId:

  The id of the cheetah table to create a proxy for.

- session:

  The Shiny session object. The default is to get the current session.

## Value

A proxy object that can be used to modify the grid.
