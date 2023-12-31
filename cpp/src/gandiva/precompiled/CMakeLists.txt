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

project(gandiva)

set(PRECOMPILED_SRCS
    arithmetic_ops.cc
    bitmap.cc
    decimal_ops.cc
    decimal_wrapper.cc
    extended_math_ops.cc
    hash.cc
    print.cc
    string_ops.cc
    time.cc
    timestamp_arithmetic.cc
    ../../arrow/util/basic_decimal.cc)

if(MSVC)
  # clang pretends to be a particular version of MSVC. Thestandard
  # library uses C++14 features, so we have to use that -std version
  # to get the IR compilation to work.
  # See https://cmake.org/cmake/help/latest/variable/MSVC_VERSION.html
  # for MSVC_VERSION and Visual Studio version.
  if(MSVC_VERSION LESS 1930)
    set(FMS_COMPATIBILITY 19.20)
  elseif(MSVC_VERSION LESS 1920)
    set(FMS_COMPATIBILITY 19.10)
  else()
    message(FATAL_ERROR "Unsupported MSVC_VERSION=${MSVC_VERSION}")
  endif()
  set(PLATFORM_CLANG_OPTIONS -std=c++17 -fms-compatibility
                             -fms-compatibility-version=${FMS_COMPATIBILITY})
else()
  set(PLATFORM_CLANG_OPTIONS -std=c++17)
endif()

# Create bitcode for each of the source files.
foreach(SRC_FILE ${PRECOMPILED_SRCS})
  get_filename_component(SRC_BASE ${SRC_FILE} NAME_WE)
  get_filename_component(ABSOLUTE_SRC ${SRC_FILE} ABSOLUTE)
  set(BC_FILE ${CMAKE_CURRENT_BINARY_DIR}/${SRC_BASE}.bc)
  set(PRECOMPILE_COMMAND)
  if(CMAKE_OSX_SYSROOT)
    list(APPEND
         PRECOMPILE_COMMAND
         ${CMAKE_COMMAND}
         -E
         env
         SDKROOT=${CMAKE_OSX_SYSROOT})
  endif()
  list(APPEND
       PRECOMPILE_COMMAND
       ${CLANG_EXECUTABLE}
       ${PLATFORM_CLANG_OPTIONS}
       -DGANDIVA_IR
       -DNDEBUG # DCHECK macros not implemented in precompiled code
       -DARROW_STATIC # Do not set __declspec(dllimport) on MSVC on Arrow symbols
       -DGANDIVA_STATIC # Do not set __declspec(dllimport) on MSVC on Gandiva symbols
       -fno-use-cxa-atexit # Workaround for unresolved __dso_handle
       -emit-llvm
       -O3
       -c
       ${ABSOLUTE_SRC}
       -o
       ${BC_FILE}
       ${ARROW_GANDIVA_PC_CXX_FLAGS}
       -I${CMAKE_SOURCE_DIR}/src
       -I${ARROW_BINARY_DIR}/src)

  if(NOT ARROW_USE_NATIVE_INT128)
    foreach(boost_include_dir ${Boost_INCLUDE_DIRS})
      list(APPEND PRECOMPILE_COMMAND -I${boost_include_dir})
    endforeach()
  endif()
  add_custom_command(OUTPUT ${BC_FILE}
                     COMMAND ${PRECOMPILE_COMMAND}
                     DEPENDS ${SRC_FILE})
  list(APPEND BC_FILES ${BC_FILE})
endforeach()

# link all of the bitcode files into a single bitcode file.
add_custom_command(OUTPUT ${GANDIVA_PRECOMPILED_BC_PATH}
                   COMMAND ${LLVM_LINK_EXECUTABLE} -o ${GANDIVA_PRECOMPILED_BC_PATH}
                           ${BC_FILES}
                   DEPENDS ${BC_FILES})

# turn the bitcode file into a C++ static data variable.
add_custom_command(OUTPUT ${GANDIVA_PRECOMPILED_CC_PATH}
                   COMMAND ${PYTHON_EXECUTABLE}
                           "${CMAKE_CURRENT_SOURCE_DIR}/../make_precompiled_bitcode.py"
                           ${GANDIVA_PRECOMPILED_CC_IN_PATH}
                           ${GANDIVA_PRECOMPILED_BC_PATH} ${GANDIVA_PRECOMPILED_CC_PATH}
                   DEPENDS ${GANDIVA_PRECOMPILED_CC_IN_PATH}
                           ${GANDIVA_PRECOMPILED_BC_PATH})

add_custom_target(precompiled ALL DEPENDS ${GANDIVA_PRECOMPILED_BC_PATH}
                                          ${GANDIVA_PRECOMPILED_CC_PATH})

# testing
if(ARROW_BUILD_TESTS)
  add_executable(gandiva-precompiled-test
                 ../context_helper.cc
                 bitmap_test.cc
                 bitmap.cc
                 epoch_time_point_test.cc
                 time_test.cc
                 time.cc
                 timestamp_arithmetic.cc
                 ../cast_time.cc
                 ../../arrow/vendored/datetime/tz.cpp
                 hash_test.cc
                 hash.cc
                 string_ops_test.cc
                 string_ops.cc
                 arithmetic_ops_test.cc
                 arithmetic_ops.cc
                 extended_math_ops_test.cc
                 extended_math_ops.cc
                 decimal_ops_test.cc
                 decimal_ops.cc
                 ../decimal_type_util.cc
                 ../decimal_xlarge.cc)
  target_include_directories(gandiva-precompiled-test PRIVATE ${CMAKE_SOURCE_DIR}/src)
  target_link_libraries(gandiva-precompiled-test PRIVATE ${ARROW_TEST_LINK_LIBS})
  target_compile_definitions(gandiva-precompiled-test PRIVATE GANDIVA_UNIT_TEST=1
                                                              ARROW_STATIC GANDIVA_STATIC)
  set(TEST_PATH "${EXECUTABLE_OUTPUT_PATH}/gandiva-precompiled-test")
  add_test(gandiva-precompiled-test ${TEST_PATH})
  set_property(TEST gandiva-precompiled-test
               APPEND
               PROPERTY LABELS "unittest;gandiva-tests")
  add_dependencies(gandiva-tests gandiva-precompiled-test)
endif()
