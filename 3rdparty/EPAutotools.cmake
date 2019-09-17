include(CompilerFlags.cmake)
include(CompilerBinaries.cmake)
include(ProcessorCount)

function(ExternalProjectAutotools EXTERNAL_PROJECT_NAME)
  pkg_check_modules(LIBNAME QUIET ${EXTERNAL_PROJECT_NAME})
  if (NOT LIBNAME_FOUND)
    message(STATUS "External project ${EXTERNAL_PROJECT_NAME} not found, will have to be built.")

    set(options)
    set(oneValueArgs URL URL_HASH)
    set(multipleValueArgs DEPENDS CONFIGURE_ARGUMENTS EXTRA_ARGUMENTS EXTRA_LDFLAGS)
    cmake_parse_arguments(EPA "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    CheckIfTarballCachedLocally(EPA_URL)

    FilterDependsList(EPA_DEPENDS)

    set(EPA_TOOLCHAIN_ENV
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

    SET(EPA_CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${EPA_TOOLCHAIN_ENV}
      ./configure --prefix=${THIRDPARTY_PREFIX})

    if (HOST_TRIPLE)
      list(APPEND EPA_CONFIGURE_COMMAND --host ${HOST_TRIPLE})
    endif(HOST_TRIPLE)
    
    if (NOT BUILD_SHARED_LIBS)
      list(APPEND EPA_CONFIGURE_COMMAND --disable-shared)
    endif()

    ProcessorCount(CPU_COUNT)
    if (CPU_COUNT)
      SET(EPA_CPU_COUNT --jobs=${CPU_COUNT})
    endif(CPU_COUNT)

    ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
      ${EPA_DEPENDS}

      URL ${EPA_URL}
      URL_HASH ${EPA_URL_HASH}

      BUILD_IN_SOURCE 1

      CONFIGURE_COMMAND ${EPA_CONFIGURE_COMMAND} ${EPA_CONFIGURE_ARGUMENTS}
      BUILD_COMMAND make ${EPA_CPU_COUNT}

      ${EPA_EXTRA_ARGUMENTS}

      LOG_DOWNLOAD 1
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
    )
  endif(NOT LIBNAME_FOUND)
endfunction(ExternalProjectAutotools)
