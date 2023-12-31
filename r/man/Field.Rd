% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/field.R
\name{field}
\alias{field}
\title{Create a Field}
\usage{
field(name, type, metadata, nullable = TRUE)
}
\arguments{
\item{name}{field name}

\item{type}{logical type, instance of \link{DataType}}

\item{metadata}{currently ignored}

\item{nullable}{TRUE if field is nullable}
}
\description{
Create a Field
}
\examples{
field("x", int32())
}
\seealso{
\link{Field}
}
