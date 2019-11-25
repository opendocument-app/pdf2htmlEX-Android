# EPCMake.cmake
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


include(ExternalProject)

function(GetCMakeArguments OUTPUT_VAR)
  set(multipleValueArgs FORCED_ARGUMENTS IGNORED_ARGUMENTS)
  cmake_parse_arguments(GCMA "" "" "${multipleValueArgs}" ${ARGN})

  # Inspired by https://stackoverflow.com/questions/10205986/how-to-capture-cmake-command-line-arguments
  get_cmake_property(CACHE_VARS CACHE_VARIABLES)
  SET(CMAKE_ARGS)
  foreach(CACHE_VAR ${CACHE_VARS})
    get_property(CACHE_VAR_HELPSTRING CACHE ${CACHE_VAR} PROPERTY HELPSTRING)

    if(CACHE_VAR IN_LIST GCMA_FORCED_ARGUMENTS OR CACHE_VAR_HELPSTRING STREQUAL "No help, variable specified on the command line.")
      get_property(CACHE_VAR_TYPE CACHE ${CACHE_VAR} PROPERTY TYPE)
      if(CACHE_VAR_TYPE STREQUAL "UNINITIALIZED")
        set(CACHE_VAR_TYPE)
      else()
        set(CACHE_VAR_TYPE :${CACHE_VAR_TYPE})
      endif()
      if(NOT CACHE_VAR IN_LIST GCMA_IGNORED_ARGUMENTS)
        LIST(APPEND CMAKE_ARGS "-D${CACHE_VAR}${CACHE_VAR_TYPE}=${${CACHE_VAR}}")
      endif()
    endif()
  endforeach()

  SET(${OUTPUT_VAR} ${CMAKE_ARGS} PARENT_SCOPE)
endfunction(GetCMakeArguments)

if(DEFINED CMAKE_TOOLCHAIN_FILE)
  SET(CompilerFlagsCMAKE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/CompilerFlags.cmake)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/CMakeToolchainWrapper.in ${THIRDPARTY_PREFIX}/CMakeToolchainWrapper.cmake @ONLY)
endif()

function(ExternalProjectCMake EXTERNAL_PROJECT_NAME)
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

  GetCMakeArguments("EP_CMAKE_ARGUMENTS"
    FORCED_ARGUMENTS "CMAKE_VERBOSE_MAKEFILE" "CMAKE_BUILD_TYPE"
    IGNORED_ARGUMENTS "CMAKE_LIBRARY_OUTPUT_DIRECTORY" "CMAKE_TOOLCHAIN_FILE" )

  if (NOT BUILD_SHARED_LIBS)
    SET(SHARED_LIBS_ARGUMENT -DBUILD_SHARED_LIBS=OFF)
  endif (NOT BUILD_SHARED_LIBS)

  if (DEFINED CompilerFlagsCMAKE_FILE)
    SET(ToolchainWrapper -DCMAKE_TOOLCHAIN_FILE=${THIRDPARTY_PREFIX}/CMakeToolchainWrapper.cmake)
  endif()

  ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    ${EP_DEPENDS}
    URL ${EP_URL}
    URL_HASH ${EP_URL_HASH}

    CMAKE_ARGS ${EP_CMAKE_ARGUMENTS}
      ${ToolchainWrapper}
      -DCMAKE_PREFIX_PATH=${THIRDPARTY_PREFIX}
      -DCMAKE_INSTALL_PREFIX=${THIRDPARTY_PREFIX}
      -DCMAKE_FIND_ROOT_PATH=${THIRDPARTY_PREFIX}
      -DPKG_CONFIG_PATH=${THIRDPARTY_PKG_CONFIG_PATH}
      -DPKG_CONFIG_LIBDIR=${THIRDPARTY_PKG_CONFIG_LIBDIR}
      -DPKG_CONFIG_EXECUTABLE=${THIRDPARTY_PKG_CONFIG_EXECUTABLE}
      ${SHARED_LIBS_ARGUMENT}
      ${EP_CONFIGURE_ARGUMENTS}

    ${EP_PATCH_SOURCE_COMMAND}
    ${EP_PATCH_INSTALL_COMMAND}
    ${EP_EXTRA_ARGUMENTS}

    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
  )
endfunction(ExternalProjectCMake)

