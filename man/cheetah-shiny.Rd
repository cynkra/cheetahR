% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cheetah.R
\name{cheetah-shiny}
\alias{cheetah-shiny}
\alias{cheetahOutput}
\alias{renderCheetah}
\title{Shiny bindings for cheetah}
\usage{
cheetahOutput(outputId, width = "100\%", height = "400px")

renderCheetah(expr, env = parent.frame(), quoted = FALSE)
}
\arguments{
\item{outputId}{output variable to read from}

\item{width, height}{Must be a valid CSS unit (like \code{'100\%'},
\code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
string and have \code{'px'} appended.}

\item{expr}{An expression that generates a cheetah}

\item{env}{The environment in which to evaluate \code{expr}.}

\item{quoted}{Is \code{expr} a quoted expression (with \code{quote()})? This
is useful if you want to save an expression in a variable.}
}
\value{
\code{cheetahOutput} returns a Shiny output function that can be used in the UI definition.
\code{renderCheetah} returns a Shiny render function that can be used in the server definition.
}
\description{
Output and render functions for using cheetah within Shiny
applications and interactive Rmd documents.
}
