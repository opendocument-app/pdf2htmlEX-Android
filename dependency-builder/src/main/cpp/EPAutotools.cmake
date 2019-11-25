# EPAutotools.cmake
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
include(ProcessorCount)

function(ExternalProjectAutotools EXTERNAL_PROJECT_NAME)
  set(options)
  set(oneValueArgs URL URL_HASH)
  set(multipleValueArgs DEPENDS CONFIGURE_ARGUMENTS EXTRA_ARGUMENTS EXTRA_ENVVARS)
  cmake_parse_arguments(EP "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

  FilterDependsList(EP_DEPENDS)
  CheckIfPackageAlreadyBuilt(${EXTERNAL_PROJECT_NAME})
  if ("${${EXTERNAL_PROJECT_NAME}_FOUND}")
    return()
  endif()

  CheckIfTarballCachedLocally(${EXTERNAL_PROJECT_NAME} EP_URL)
  CheckIfSourcePatchExists(${EXTERNAL_PROJECT_NAME} EP_PATCH_SOURCE_COMMAND)
  CheckIfInstallPatchExists(${EXTERNAL_PROJECT_NAME} EP_PATCH_INSTALL_COMMAND)

  set(EP_TOOLCHAIN_ENV
    AS=${AS}
    AR=${CMAKE_AR}
    CC=${CC}
    CXX=${CXX}
    LD=${CMAKE_LINKER}
    NM=${CMAKE_NM}
    OBJDUMP=${CMAKE_OBJDUMP}
    RANLIB=${CMAKE_RANLIB}
    STRIP=${CMAKE_STRIP}

    PKG_CONFIG_PATH=${THIRDPARTY_PKG_CONFIG_PATH}
    PKG_CONFIG_LIBDIR=${THIRDPARTY_PKG_CONFIG_LIBDIR}
    PKG_CONFIG=${THIRDPARTY_PKG_CONFIG_EXECUTABLE}

    CFLAGS=${CFLAGS}
    CXXFLAGS=${CXXFLAGS}
    LDFLAGS=${LDFLAGS}
  )
  LIST(APPEND EP_TOOLCHAIN_ENV ${EP_EXTRA_ENVVARS})

  SET(EP_CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${EP_TOOLCHAIN_ENV}
    ./configure
      --prefix=${THIRDPARTY_PREFIX}
      --oldincludedir=${THIRDPARTY_PREFIX}/include
  )

  if (HOST_TRIPLE)
    list(APPEND EP_CONFIGURE_COMMAND --host ${HOST_TRIPLE})
  endif(HOST_TRIPLE)

  if (NOT BUILD_SHARED_LIBS)
    list(APPEND EP_CONFIGURE_COMMAND --disable-shared)
  endif()

  ProcessorCount(CPU_COUNT)
  if (CPU_COUNT)
    SET(EP_CPU_COUNT -j${CPU_COUNT})
  endif(CPU_COUNT)

  ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    ${EP_DEPENDS}

    URL ${EP_URL}
    URL_HASH ${EP_URL_HASH}

    BUILD_IN_SOURCE 1

    CONFIGURE_COMMAND ${EP_CONFIGURE_COMMAND} ${EP_CONFIGURE_ARGUMENTS}
    BUILD_COMMAND make ${EP_CPU_COUNT}

    ${EP_PATCH_SOURCE_COMMAND}
    ${EP_PATCH_INSTALL_COMMAND}
    ${EP_EXTRA_ARGUMENTS}

    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
  )
endfunction(ExternalProjectAutotools)

