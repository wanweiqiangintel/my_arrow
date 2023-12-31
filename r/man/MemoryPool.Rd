% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/memory-pool.R
\docType{class}
\name{MemoryPool}
\alias{MemoryPool}
\title{MemoryPool class}
\description{
MemoryPool class
}
\section{Methods}{

\itemize{
\item \code{backend_name}: one of "jemalloc", "mimalloc", or "system". Alternative
memory allocators are optionally enabled at build time. Windows builds
generally have \code{mimalloc}, and most others have both \code{jemalloc} (used by
default) and \code{mimalloc}. To change memory allocators at runtime, set the
environment variable \code{ARROW_DEFAULT_MEMORY_POOL} to one of those strings
prior to loading the \code{arrow} library.
\item \code{bytes_allocated}
\item \code{max_memory}
}
}

\keyword{internal}
