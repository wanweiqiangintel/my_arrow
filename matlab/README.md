<!---
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
-->

# MATLAB Interface to Apache Arrow

## Status

> **Warning** The MATLAB interface is under active development and should be considered experimental.

This is a very early stage MATLAB interface to the Apache Arrow C++ libraries.

Currently, the MATLAB interface supports:

1. Creating a subset of Arrow `Array` types (e.g. numeric and boolean) from MATLAB data
2. Reading and writing numeric types from/to Feather v1 files.

Supported `arrow.array.Array` types are included in the table below.

**NOTE**: All Arrow `Array` classes are part of the `arrow.array` package (e.g. `arrow.array.Float64Array`).

| MATLAB Array Type | Arrow Array Type |
| ----------------- | ---------------- |
| `single`          | `Float32Array`   |
| `double`          | `Float64Array`   |
| `uint8`           | `UInt8Array`     |
| `uint16`          | `UInt16Array`    |
| `uint32`          | `UInt32Array`    |
| `uint64`          | `UInt64Array`    |
| `int8`            | `Int8Array`      |
| `int16`           | `Int16Array`     |
| `int32`           | `Int32Array`     |
| `int64`           | `Int64Array`     |
| `logical`         | `BooleanArray`   |

## Prerequisites

To build the MATLAB Interface to Apache Arrow from source, the following software must be installed on the target machine:

1. [MATLAB](https://www.mathworks.com/products/get-matlab.html)
2. [CMake](https://cmake.org/cmake/help/latest/)
3. C++ compiler which supports C++17 (e.g. [`gcc`](https://gcc.gnu.org/) on Linux, [`Xcode`](https://developer.apple.com/xcode/) on macOS, or [`Visual Studio`](https://visualstudio.microsoft.com/) on Windows)
4. [Git](https://git-scm.com/)

## Setup

To set up a local working copy of the source code, start by cloning the [`apache/arrow`](https://github.com/apache/arrow) GitHub repository using [Git](https://git-scm.com/):

```console
$ git clone https://github.com/apache/arrow.git
```

After cloning, change the working directory to the `matlab` subdirectory:

```console
$ cd arrow/matlab
```

## Build

To build the MATLAB interface, use [CMake](https://cmake.org/cmake/help/latest/):

```console
$ cmake -S . -B build -D MATLAB_ARROW_INTERFACE=ON
$ cmake --build build --config Release
```

**NOTE:** To build the experimental MATLAB interface code, `-D MATLAB_ARROW_INTERFACE=ON` must be specified as shown above.

## Install

To install the MATLAB interface to the default software installation location for the target machine (e.g. `/usr/local` on Linux or `C:\Program Files` on Windows), pass the `--target install` flag to CMake.

```console
$ cmake --build build --config Release --target install
```

As part of the install step, the installation directory is added to the [MATLAB Search Path](https://mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html).

**Note**: This step may fail if the current user is lacking necessary filesystem permissions. If the install step fails, the installation directory can be manually added to the MATLAB Search Path using the [`addpath`](https://www.mathworks.com/help/matlab/ref/addpath.html) command. 

## Test

There are two kinds of tests for the MATLAB Interface: MATLAB and C++. 

### MATLAB

To run the MATLAB tests, start MATLAB in the `arrow/matlab` directory and call the [`runtests`](https://mathworks.com/help/matlab/ref/runtests.html) command on the `test` directory with `IncludeSubFolders=true`:

``` matlab
>> runtests("test", IncludeSubFolders=true);
```

### C++

To enable the C++ tests, set the `MATLAB_BUILD_TESTS` flag to `ON` at build time: 

```console
$ cmake -S . -B build -D MATLAB_ARROW_INTERFACE=ON -D MATLAB_BUILD_TESTS=ON
$ cmake --build build --config Release
```

After building with the `MATLAB_BUILD_TESTS` flag enabled, the C++ tests can be run using [CTest](https://cmake.org/cmake/help/latest/manual/ctest.1.html):

```console
$ ctest --test-dir build
```

## Usage

Included below are some example code snippets that illustrate how to use the MATLAB interface.

### Arrow `Array` classes (i.e. `arrow.array.<Array>`)

#### Create an Arrow `Float64Array` from a MATLAB `double` array

```matlab
>> matlabArray = double([1, 2, 3])

matlabArray =

     1     2     3

>> arrowArray = arrow.array.Float64Array(matlabArray)

arrowArray = 

[
  1,
  2,
  3
]
```

#### Create a MATLAB `logical` array from an Arrow `BooleanArray`

```matlab
>> arrowArray = arrow.array.BooleanArray([true, false, true])

arrowArray = 

[
  true,
  false,
  true
]

>> matlabArray = toMATLAB(arrowArray)

matlabArray =

  3×1 logical array

   1
   0
   1
```

#### Specify `Null` Values when constructing an `arrow.array.Int8Array`

```matlab
>> matlabArray = int8([122, -1, 456, -10, 789])

matlabArray =

  1×5 int8 row vector

    122     -1    127    -10    127

% Treat all negative array elements as Null
>> validElements = matlabArray > 0

validElements =

  1×5 logical array

   1   0   1   0   1

% Specify which values are Null/Valid by supplying a logical validity "mask"
>> arrowArray = arrow.array.Int8Array(matlabArray, Valid=validElements)

arrowArray = 

[
  122,
  null,
  127,
  null,
  127
]
```

### Feather V1

#### Write a MATLAB table to a Feather v1 file

``` matlab
>> t = array2table(rand(10, 10));
>> filename = 'table.feather';
>> featherwrite(filename,t);
```

#### Read a Feather v1 file into a MATLAB table

``` matlab
>> filename = 'table.feather';
>> t = featherread(filename);
```

