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
  include(${CMAKE_CURRENT_SOURCE_DIR}/packages/${PACKAGE_NAME}.cmake)
  if (${${PACKAGE_NAME}_FOUND} MATCHES 1)
    SET("${PACKAGE_NAME}_FOUND" 1 PARENT_SCOPE)
    return()
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

  SET(EP_DEPENDS_FILTERED DEPENDS)

  foreach(DEPENDENCY ${EP_DEPENDS})
    CheckIfPackageAlreadyBuilt(${DEPENDENCY})
    if(NOT "${DEPENDENCY}_FOUND" AND TARGET ${DEPENDENCY})
      LIST(APPEND EP_DEPENDS_FILTERED ${DEPENDENCY})
    endif()
  endforeach()

  CheckIfTarballCachedLocally(${EXTERNAL_PROJECT_NAME} EP_URL)
  GenerateSourcePatchCall(${EXTERNAL_PROJECT_NAME} EP_PATCH_SOURCE_COMMAND)

  SET(INSTALL_PATCH_ENV ANDROID=${ANDROID} ANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL})
  SET(EP_PATCH_INSTALL_COMMAND TEST_COMMAND
    ${CMAKE_COMMAND} -E env ${INSTALL_PATCH_ENV}
    ${CMAKE_CURRENT_SOURCE_DIR}/Patch-Package-Install
    --cmakeBinaryDir=${CMAKE_CURRENT_BINARY_DIR}
    --installPrefix=${THIRDPARTY_PREFIX}
    --project=${EXTERNAL_PROJECT_NAME}
    )

  SET(EP_DEPENDS ${EP_DEPENDS_FILTERED})
endmacro(ExternalProjectHeaderBoilerplate)

