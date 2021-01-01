# EPHelpers.cmake
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


function(CheckIfPackageAlreadyBuilt PACKAGE_NAME)
  if("${PACKAGE_NAME}" STREQUAL "iconv" AND ANDROID_NATIVE_API_LEVEL GREATER_EQUAL 28)
    # ANDROID-28+ has iconv built in.
    SET("${PACKAGE_NAME}_FOUND" 1 PARENT_SCOPE)
    return()

  elseif("${PACKAGE_NAME}" STREQUAL "libtool")
    # libtool does not have pkg-config.pc. Check if libltdl.a exists.
    if (EXISTS ${THIRDPARTY_PREFIX}/lib/libltdl.a)
      SET("${PACKAGE_NAME}_FOUND" 1 PARENT_SCOPE)
      return()
    endif()

  elseif("${PACKAGE_NAME}" STREQUAL "pdf2htmlEX")
    if (EXISTS ${JNILIBS_FOR_DOWNSTREAM_AAR}/libpdf2htmlEX.so)
      SET("${PACKAGE_NAME}_FOUND" 1 PARENT_SCOPE)
      return()
    endif()
  endif()

  # Check pkg-config
  pkg_search_module("${PACKAGE_NAME}_PKG" QUIET "${PACKAGE_NAME}")
  if (${${PACKAGE_NAME}_PKG_FOUND})
    SET("${PACKAGE_NAME}_FOUND" 1 PARENT_SCOPE)
    return()
  endif()

  # Try to find package through CMake
  find_package("${PACKAGE_NAME}_CMAKE" QUIET)
  if ("${${PACKAGE_NAME}_CMAKE_FOUND}")
    SET("${PACKAGE_NAME}_FOUND" 1 PARENT_SCOPE)
    return()
  endif()

  SET("${PACKAGE_NAME}_FOUND" 0 PARENT_SCOPE)
endfunction(CheckIfPackageAlreadyBuilt)

function(CheckIfTarballCachedLocally EP_NAME URL)
  # Expand URL variable twice, to get the INPUT value
  SET(INPUT ${${URL}})

  get_filename_component(FILENAME ${INPUT} NAME)

  SET(CACHED_FILENAME ${TARBALL_STORAGE}/${EP_NAME}/${FILENAME})
  if (EXISTS ${CACHED_FILENAME})
    SET(${URL} ${CACHED_FILENAME} PARENT_SCOPE)
  elseif (EXISTS "${CACHED_FILENAME}.tar")
    SET(${URL} "${CACHED_FILENAME}.tar" PARENT_SCOPE)
  endif()
endfunction(CheckIfTarballCachedLocally)

function(GenerateSourcePatchCall EXTERNAL_PROJECT_NAME OUTPUT_VAR)
  SET(PATCH_ENV ANDROID=${ANDROID} ANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL})
  SET(PATCH_FILENAME ${CMAKE_CURRENT_SOURCE_DIR}/packages/${EXTERNAL_PROJECT_NAME}-Patch-Source.sh)
  SET(PROJECT_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME})
  SET(${OUTPUT_VAR} UPDATE_COMMAND
    ${CMAKE_COMMAND} -E env ${PATCH_ENV}
    ${CMAKE_CURRENT_SOURCE_DIR}/Patch-Package-Source.sh ${EXTERNAL_PROJECT_NAME} ${PROJECT_SRC_DIR} ${THIRDPARTY_PREFIX}
    LOG_UPDATE 1
    PARENT_SCOPE)
endfunction(GenerateSourcePatchCall)

function(CheckIfInstallPatchExists EXTERNAL_PROJECT_NAME OUTPUT_VAR)
  SET(PATCH_ENV ANDROID=${ANDROID} ANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL})

  set(PATCH_FILENAME ${CMAKE_CURRENT_SOURCE_DIR}/packages/${EXTERNAL_PROJECT_NAME}-Patch-Install.sh)
  set(PROJECT_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME})
  if (EXISTS ${PATCH_FILENAME})
    SET(${OUTPUT_VAR} TEST_COMMAND
      ${CMAKE_COMMAND} -E env ${PATCH_ENV}
      ${PATCH_FILENAME} ${PROJECT_SRC_DIR} ${THIRDPARTY_PREFIX}
      LOG_TEST 1
      PARENT_SCOPE)
  else()
    SET(${OUTPUT_VAR} "" PARENT_SCOPE)
  endif()
endfunction(CheckIfInstallPatchExists)

macro(ExternalProjectHeaderBoilerplate)
  CheckIfPackageAlreadyBuilt(${EXTERNAL_PROJECT_NAME})
  if ("${${EXTERNAL_PROJECT_NAME}_FOUND}")
    add_custom_target(${PACKAGE_NAME} COMMAND /bin/true)
    return()
  endif()

  set(options)
  set(oneValueArgs URL URL_HASH)
  set(multipleValueArgs DEPENDS CONFIGURE_ARGUMENTS EXTRA_ARGUMENTS EXTRA_ENVVARS)
  cmake_parse_arguments(EP "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

  foreach(DEPENDENCY ${EP_DEPENDS})
    include("${CMAKE_CURRENT_SOURCE_DIR}/packages/${DEPENDENCY}.cmake")
  endforeach()

  CheckIfTarballCachedLocally(${EXTERNAL_PROJECT_NAME} EP_URL)
  GenerateSourcePatchCall(${EXTERNAL_PROJECT_NAME} EP_PATCH_SOURCE_COMMAND)
  CheckIfInstallPatchExists(${EXTERNAL_PROJECT_NAME} EP_PATCH_INSTALL_COMMAND)

  LIST(INSERT EP_DEPENDS 0 DEPENDS)
endmacro(ExternalProjectHeaderBoilerplate)

