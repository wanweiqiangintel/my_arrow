% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/buffer.R
\docType{class}
\name{Buffer}
\alias{Buffer}
\title{Buffer class}
\description{
A Buffer is an object containing a pointer to a piece of
contiguous memory with a particular size.
}
\section{Factory}{

\code{buffer()} lets you create an \code{arrow::Buffer} from an R object
}

\section{Methods}{

\itemize{
\item \verb{$is_mutable} : is this buffer mutable?
\item \verb{$ZeroPadding()} : zero bytes in padding, i.e. bytes between size and capacity
\item \verb{$size} : size in memory, in bytes
\item \verb{$capacity}: possible capacity, in bytes
}
}

\examples{
my_buffer <- buffer(c(1, 2, 3, 4))
my_buffer$is_mutable
my_buffer$ZeroPadding()
my_buffer$size
my_buffer$capacity
}
