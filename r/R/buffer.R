# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

#' @title Buffer class
#' @usage NULL
#' @format NULL
#' @docType class
#' @description A Buffer is an object containing a pointer to a piece of
#' contiguous memory with a particular size.
#' @section Factory:
#' `buffer()` lets you create an `arrow::Buffer` from an R object
#' @section Methods:
#'
#' - `$is_mutable` : is this buffer mutable?
#' - `$ZeroPadding()` : zero bytes in padding, i.e. bytes between size and capacity
#' - `$size` : size in memory, in bytes
#' - `$capacity`: possible capacity, in bytes
#'
#' @rdname Buffer-class
#' @name Buffer
#' @examples
#' my_buffer <- buffer(c(1, 2, 3, 4))
#' my_buffer$is_mutable
#' my_buffer$ZeroPadding()
#' my_buffer$size
#' my_buffer$capacity
#' @export
#' @include arrow-object.R
#' @include enums.R
Buffer <- R6Class("Buffer",
  inherit = ArrowObject,
  public = list(
    ZeroPadding = function() Buffer__ZeroPadding(self),
    data = function() Buffer__data(self),
    Equals = function(other, ...) {
      inherits(other, "Buffer") && Buffer__Equals(self, other)
    }
  ),
  active = list(
    is_mutable = function() Buffer__is_mutable(self),
    size = function() Buffer__size(self),
    capacity = function() Buffer__capacity(self)
  )
)

Buffer$create <- function(x) {
  if (inherits(x, "Buffer")) {
    x
  } else if (inherits(x, c("raw", "numeric", "integer", "complex"))) {
    r___RBuffer__initialize(x)
  } else if (inherits(x, "BufferOutputStream")) {
    x$finish()
  } else {
    stop("Cannot convert object of class ", class(x), " to arrow::Buffer")
  }
}

#' Create a Buffer
#' @rdname buffer
#' @param x R object. Only raw, numeric and integer vectors are currently supported
#' @return an instance of `Buffer` that borrows memory from `x`
#' @seealso [Buffer]
#' @export
buffer <- Buffer$create

#' @export
as.raw.Buffer <- function(x) x$data()
