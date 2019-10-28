# EPHelpers.cmake
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


function(CheckIfPackageAlreadyBuilt PACKAGE_NAME)
  if("${PACKAGE_NAME}" STREQUAL "iconv" AND ANDROID_NATIVE_API_LEVEL GREATER_EQUAL 28)
    # ANDROID-28+ has iconv built in.
    SET(PACKAGE_FOUND 1 PARENT_SCOPE)
    return()

  elseif("${PACKAGE_NAME}" STREQUAL "libtool")
    # libtool does not have pkg-config.pc. Check if libltdl.a exists.
    if (EXISTS ${THIRDPARTY_PREFIX}/lib/libltdl.a)
      SET(PACKAGE_FOUND 1 PARENT_SCOPE)
      return()
    endif()
  endif()

  # Check pkg-config
  pkg_check_modules(PKG QUIET ${PACKAGE_NAME})
  if (PKG_FOUND)
    SET(PACKAGE_FOUND 1 PARENT_SCOPE)
    return()
  endif()

  # Try to find package through CMake
  find_package(${PACKAGE_NAME} QUIET)
  if (${PACKAGE_NAME}_FOUND)
    SET(PACKAGE_FOUND 1 PARENT_SCOPE)
    return()
  endif()

  SET(PACKAGE_FOUND 0 PARENT_SCOPE)

endfunction(CheckIfPackageAlreadyBuilt)

# DEPEND only on those ExternalProjects that we can actually find as targets
# No target? Check if it's already installed
# Not found? Error!
function(FilterDependsList DEPENDS_LIST)
  # Expand DEPENDS_LIST variable twice, to get the INPUT value
  SET(INPUT ${${DEPENDS_LIST}})
  SET(RESULT)

  if(INPUT)
    foreach(DEPENDENCY IN ITEMS ${INPUT})
      # Check if we have a package file for this dependency
      SET(PACKAGE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/packages/${DEPENDENCY}.cmake)
      include(${PACKAGE_FILE} OPTIONAL)

      if (TARGET ${DEPENDENCY})
        list(APPEND RESULT ${DEPENDENCY})

      else()
        CheckIfPackageAlreadyBuilt(${DEPENDENCY})
        if (NOT PACKAGE_FOUND)
          message(FATAL_ERROR "Missing dependency ${DEPENDENCY}!")
        endif()
      endif()

    endforeach(DEPENDENCY IN ITEMS ${INPUT})

    if (RESULT)
      SET(RESULT DEPENDS ${RESULT})
    endif(RESULT)
  endif(INPUT)

  SET(${DEPENDS_LIST} ${RESULT} PARENT_SCOPE)
endfunction(FilterDependsList)

function(CheckIfTarballCachedLocally URL)
  # Expand URL variable twice, to get the INPUT value
  SET(INPUT ${${URL}})

  get_filename_component(FILENAME ${INPUT} NAME)

  SET(CACHED_FILENAME ${TARBALL_STORAGE}/${FILENAME})
  if (EXISTS ${CACHED_FILENAME})
    SET(${URL} ${CACHED_FILENAME} PARENT_SCOPE)
  endif()

endfunction(CheckIfTarballCachedLocally)

function(CheckIfSourcePatchExists EXTERNAL_PROJECT_NAME OUTPUT_VAR)
  SET(PATCH_ENV ANDROID=${ANDROID} ANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL})

  set(PATCH_FILENAME ${CMAKE_CURRENT_SOURCE_DIR}/packages/${EXTERNAL_PROJECT_NAME}-Patch-Source.sh)
  set(PROJECT_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME})
  if (EXISTS ${PATCH_FILENAME})
    SET(${OUTPUT_VAR} UPDATE_COMMAND
      ${CMAKE_COMMAND} -E env ${PATCH_ENV}
      ${PATCH_FILENAME} ${PROJECT_SRC_DIR} ${THIRDPARTY_PREFIX}
      LOG_UPDATE 1
      PARENT_SCOPE)
  else()
    SET(${OUTPUT_VAR} "" PARENT_SCOPE)
  endif()
endfunction(CheckIfSourcePatchExists)

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

