cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)

set(CMAKE_BUILD_TYPE Release CACHE STRING "Build configuration (Debug, Release, RelWithDebInfo, MinSizeRel)")

project(ThirdPartyBuilder)

message(STATUS "Running 3rdparty library build")

include(ExternalProject)
find_package(PkgConfig REQUIRED)


SET(THIRDPARTY_PREFIX ${CMAKE_CURRENT_LIST_DIR}/build/${CMAKE_BUILD_TYPE}/${ANDROID_ABI})
SET(THIRDPARTY_PKG_CONFIG_PATH ${THIRDPARTY_PREFIX}/share/pkgconfig)
SET(THIRDPARTY_PKG_CONFIG_LIBDIR ${THIRDPARTY_PREFIX}/lib/pkgconfig)
SET(THIRDPARTY_PKG_CONFIG_EXECUTABLE ${THIRDPARTY_PREFIX}/bin/pkg-config)
SET(PKG_CONFIG_EXECUTABLE ${THIRDPARTY_PKG_CONFIG_EXECUTABLE})

# LIST(PREPEND is unavailable in CMake 3.10)
LIST(REVERSE CMAKE_FIND_ROOT_PATH)
LIST(APPEND CMAKE_FIND_ROOT_PATH ${THIRDPARTY_PREFIX})
LIST(REVERSE CMAKE_FIND_ROOT_PATH)

# Generate pkg-config wrapper
if(BUILD_SHARED_LIBS)
  configure_file(${CMAKE_CURRENT_LIST_DIR}/pkg-config.in ${THIRDPARTY_PKG_CONFIG_EXECUTABLE} @ONLY)
else()
  configure_file(${CMAKE_CURRENT_LIST_DIR}/pkg-config-static.in ${THIRDPARTY_PKG_CONFIG_EXECUTABLE} @ONLY)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/EPHelpers.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPAutotools.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPCMake.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/EPMeson.cmake)

SET(TARBALL_STORAGE ${CMAKE_CURRENT_SOURCE_DIR}/tarballs/ CACHE PATH "Path to manually downloaded tarballs. Used to look up before downloading from the internet.")

option(BUILD_3RDPARTY_BINARIES "Build all 3rd party binaries to catch missing symbols earlier" OFF)

# List of root level packages that we want installed.
# Defined dependencies will be picked up too.

include(${CMAKE_CURRENT_SOURCE_DIR}/packages/pdf2htmlEX.cmake)

