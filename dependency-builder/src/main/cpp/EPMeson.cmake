# EPMeson.cmake
#
# pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
# Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
#
# Copyright (c) 2019 Vilius Sutkus <ViliusSutkus89@gmail.com>
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


include(CompilerFlags.cmake)
include(CompilerBinaries.cmake)

if (ANDROID)
  if(ANDROID_ABI STREQUAL armeabi-v7a)
    SET(MESON_SYSTEM "android-arm")
    SET(MESON_CPU_FAMILY "arm")
    SET(MESON_CPU "armv7-a")
  elseif(ANDROID_ABI STREQUAL arm64-v8a)
    SET(MESON_SYSTEM "android-aarch64")
    SET(MESON_CPU_FAMILY "aarch64")
    SET(MESON_CPU "aarch64")
  elseif(ANDROID_ABI STREQUAL x86)
    SET(MESON_SYSTEM "android-x86")
    SET(MESON_CPU_FAMILY "x86")
    SET(MESON_CPU "i686")
  elseif(ANDROID_ABI STREQUAL x86_64)
    SET(MESON_SYSTEM "android-x86_64")
    SET(MESON_CPU_FAMILY "x86_64")
    SET(MESON_CPU "x86_64")
  else()
    message(FATAL_ERROR "Invalid Android ABI: ${ANDROID_ABI}.")
  endif()
  set(MESON_ENDIAN "little")

  SET(MESON_CC ${CC})
  SET(MESON_CPP ${CXX})
  SET(MESON_LLVM-CONFIG ${ANDROID_TOOLCHAIN_ROOT}/bin/llvm-config)
  SET(MESON_CROSS_COMPILE_FILE ${THIRDPARTY_PREFIX}/meson_cross_file.txt)
endif()

# Provide a meson cross compile file
if (MESON_CROSS_COMPILE_FILE AND NOT EXISTS ${MESON_CROSS_COMPILE_FILE})
  configure_file(${CMAKE_CURRENT_LIST_DIR}/meson_cross_file.txt.in ${MESON_CROSS_COMPILE_FILE} @ONLY)
endif()

function(ExternalProjectMeson EXTERNAL_PROJECT_NAME)
  set(options)
  set(oneValueArgs URL URL_HASH)
  set(multipleValueArgs DEPENDS CONFIGURE_ARGUMENTS EXTRA_ARGUMENTS)
  cmake_parse_arguments(EP "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

  FilterDependsList(EP_DEPENDS)
  CheckIfPackageAlreadyBuilt(${EXTERNAL_PROJECT_NAME})
  if ("${${EXTERNAL_PROJECT_NAME}_FOUND}")
    return()
  endif()

  CheckIfTarballCachedLocally(${EXTERNAL_PROJECT_NAME} EP_URL)
  CheckIfSourcePatchExists(${EXTERNAL_PROJECT_NAME} EP_PATCH_SOURCE_COMMAND)
  CheckIfInstallPatchExists(${EXTERNAL_PROJECT_NAME} EP_PATCH_INSTALL_COMMAND)

  if (CMAKE_BUILD_TYPE STREQUAL Debug)
    set(MESON_BUILD_TYPE debug)
  elseif(CMAKE_BUILD_TYPE STREQUAL Release)
    set(MESON_BUILD_TYPE release)
  elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
    set(MESON_BUILD_TYPE debugoptimized)
  elseif(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
    set(MESON_BUILD_TYPE minsize)
  else()
    message(FATAL_ERROR "Unknown build type:" ${CMAKE_BUILD_TYPE})
  endif()

  # Meson uses Ninja.
  # CMake, provided by Android SDK, bundles Ninja.
  # Add it to PATH, so it could be used by Meson.
  get_filename_component(NINJA_PATH ${CMAKE_COMMAND} DIRECTORY)
  SET(MESON_PATH "${NINJA_PATH}/:$ENV{PATH}")

  SET(MESON_ENV
    # https://github.com/mesonbuild/meson/issues/217
    # find_library is now cc.find_library and now uses the linker to check if a particular library is available (similar to how AC_CHECK_LIB does it). This means you can set the LIBRARY_PATH env variable (when using gcc/clang and the LIBPATH env variable when using MSVC) to point to your "library providing" root. It also accepts a colon-separated list of directories. This is how almost everyone does non-default-linker-search-path library searching and linking.
    LIBRARY_PATH=${THIRDPARTY_PREFIX}/lib
    LIBPATH=${THIRDPARTY_PREFIX}/lib

    # http://mesonbuild.com/Reference-manual.html#compiler-object
    # Note that if you have a single prefix with all your dependencies, you might find it easier to append to the environment variables C_INCLUDE_PATH with GCC/Clang and INCLUDE with MSVC to expand the default include path, and LIBRARY_PATH with GCC/Clang and LIB with MSVC to expand the default library search path.
    C_INCLUDE_PATH=${THIRDPARTY_PREFIX}/include
    INCLUDE=${THIRDPARTY_PREFIX}/include

    PATH=${MESON_PATH}
  )

  set(EP_CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${MESON_ENV}
    meson --buildtype ${MESON_BUILD_TYPE}
    ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME}
    ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME}-build
  )

  if(MESON_CROSS_COMPILE_FILE)
    LIST(APPEND EP_CONFIGURE_COMMAND --cross-file ${MESON_CROSS_COMPILE_FILE})
  endif(MESON_CROSS_COMPILE_FILE)

  if (NOT BUILD_SHARED_LIBS)
    LIST(APPEND EP_CONFIGURE_COMMAND -Ddefault_library=static)
  endif (NOT BUILD_SHARED_LIBS)

  SET(NINJA_WRAPPER ${CMAKE_COMMAND} -E env ${MESON_ENV}
    ninja -C ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME}-build)

  ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    ${EP_DEPENDS}
    URL ${EP_URL}
    URL_HASH ${EP_URL_HASH}

    CONFIGURE_COMMAND ${EP_CONFIGURE_COMMAND} ${EP_CONFIGURE_ARGUMENTS}
    BUILD_COMMAND ${NINJA_WRAPPER}
    INSTALL_COMMAND ${NINJA_WRAPPER} install

    ${EP_PATCH_SOURCE_COMMAND}
    ${EP_PATCH_INSTALL_COMMAND}
    ${EP_EXTRA_ARGUMENTS}

    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
  )
endfunction(ExternalProjectMeson EXTERNAL_PROJECT_NAME)

