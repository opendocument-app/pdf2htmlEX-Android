# CMakeLists.txt
#
# pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
# Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
#
# Copyright (c) 2019 - 2021 Vilius Sutkus <ViliusSutkus89@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)

set(CMAKE_BUILD_TYPE Release CACHE STRING "Build configuration (Debug, Release, RelWithDebInfo, MinSizeRel)")

project(DependencyBuilder)

include(ExternalProject)

get_filename_component(DP_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
SET(THIRDPARTY_PREFIX ${DP_ROOT_DIR}/build/installed/${CMAKE_BUILD_TYPE}/${ANDROID_ABI})
SET(THIRDPARTY_PKG_CONFIG_PATH ${THIRDPARTY_PREFIX}/share/pkgconfig)
SET(THIRDPARTY_PKG_CONFIG_LIBDIR ${THIRDPARTY_PREFIX}/lib/pkgconfig)
SET(PKG_CONFIG_EXECUTABLE_STATIC ${THIRDPARTY_PREFIX}/bin/pkg-config)
SET(PKG_CONFIG_EXECUTABLE_DYNAMIC ${THIRDPARTY_PREFIX}/bin/pkg-config-dynamic)

# LIST(PREPEND is unavailable in CMake 3.10)
LIST(REVERSE CMAKE_FIND_ROOT_PATH)
LIST(APPEND CMAKE_FIND_ROOT_PATH ${THIRDPARTY_PREFIX})
LIST(REVERSE CMAKE_FIND_ROOT_PATH)

# Generate pkg-config wrappers
configure_file(${CMAKE_CURRENT_LIST_DIR}/pkg-config-static.in ${PKG_CONFIG_EXECUTABLE_STATIC} @ONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/pkg-config.in ${PKG_CONFIG_EXECUTABLE_DYNAMIC} @ONLY)

if(BUILD_SHARED_LIBS)
  SET(PKG_CONFIG_EXECUTABLE ${PKG_CONFIG_EXECUTABLE_DYNAMIC})
else()
  SET(PKG_CONFIG_EXECUTABLE ${PKG_CONFIG_EXECUTABLE_STATIC})
endif()
find_package(PkgConfig REQUIRED)

include(${CMAKE_CURRENT_SOURCE_DIR}/EPHelpers.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPAutotools.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPCMake.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPMeson.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPTarball.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPFiletree.cmake)

SET(TARBALL_STORAGE ${CMAKE_CURRENT_SOURCE_DIR}/tarballs/ CACHE PATH "Path to manually downloaded tarballs. Used to look up before downloading from the internet.")

option(BUILD_3RDPARTY_BINARIES "Build all 3rd party binaries to catch missing symbols earlier" OFF)

# List of root level packages that we want installed.
# Defined dependencies will be picked up too.
include(${CMAKE_CURRENT_SOURCE_DIR}/packages/pdf2htmlEX.cmake)

# This will make sure pdf2htmlEX is added to the dependency chain
add_executable(emptyProgram emptyProgram.cpp)
if (TARGET pdf2htmlEX)
  add_dependencies(emptyProgram pdf2htmlEX)
endif()

