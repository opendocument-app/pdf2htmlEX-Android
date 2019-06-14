cmake_minimum_required(VERSION 3.13.2 FATAL_ERROR)

set(CMAKE_BUILD_TYPE Release CACHE STRING "Build configuration (Debug, Release, RelWithDebInfo, MinSizeRel)")

project(ThirdPartyBuilder)

message(STATUS "Running 3rdparty library build")

include(ExternalProject)
find_package(PkgConfig REQUIRED)

# Include toolchain config
include(${CMAKE_CURRENT_SOURCE_DIR}/Toolchain.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPHelpers.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPAutotools.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPCMake.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPMeson.cmake)

# Path to manually downloaded tarballs
SET(TARBALL_STORAGE ${CMAKE_CURRENT_SOURCE_DIR}/tarballs/)

#@TODO: OPTION() not SET()
SET(BUILD_ALL_3RDPARTY_UTILS_TO_CHECK_FOR_MISSING_SYMBOLS_IN_INCLUDED_LIBRARIES 0)

# List of root level packages that we want installed.
# Defined dependencies will be picked up too.

include(${CMAKE_CURRENT_SOURCE_DIR}/packages/cairo.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/packages/libfontforge.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/packages/poppler.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/packages/freetype.cmake)
