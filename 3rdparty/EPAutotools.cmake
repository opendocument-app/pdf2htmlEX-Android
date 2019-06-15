include(ProcessorCount)

function(ExternalProjectAutotools EXTERNAL_PROJECT_NAME)
  pkg_check_modules(LIBNAME QUIET ${EXTERNAL_PROJECT_NAME})
  if (NOT LIBNAME_FOUND)
    message("External project ${EXTERNAL_PROJECT_NAME} not found, will have to be built.")

    set(options)
    set(oneValueArgs URL URL_HASH)
    set(multipleValueArgs DEPENDS CONFIGURE_ARGUMENTS EXTRA_ARGUMENTS EXTRA_LDFLAGS)
    cmake_parse_arguments(EPA "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    CheckIfTarballCachedLocally(EPA_URL)

    FilterDependsList(EPA_DEPENDS)

    SET(EPA_CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${TOOLCHAIN_ENV})

    LIST(APPEND EPA_CONFIGURE_COMMAND ./configure --prefix=${THIRDPARTY_PREFIX})

    if (ANDROID)
      list(APPEND EPA_CONFIGURE_COMMAND --host ${CMAKE_LIBRARY_ARCHITECTURE})
    endif(ANDROID)
    
    if (NOT BUILD_SHARED_LIBS)
      list(APPEND EPA_CONFIGURE_COMMAND --disable-shared)
    endif()

    list(APPEND EPA_CONFIGURE_COMMAND ${EPA_CONFIGURE_ARGUMENTS})

    SET(EPA_BUILD_COMMAND ${CMAKE_COMMAND} -E env ${TOOLCHAIN_ENV} make)

    ProcessorCount(CPU_COUNT)
    if (CPU_COUNT)
      list(APPEND EPA_BUILD_COMMAND --jobs=${CPU_COUNT})
    endif(CPU_COUNT)

    ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
      ${EPA_DEPENDS}

      URL ${EPA_URL}
      URL_HASH ${EPA_URL_HASH}

      BUILD_IN_SOURCE 1

      CONFIGURE_COMMAND ${EPA_CONFIGURE_COMMAND}
      BUILD_COMMAND ${EPA_BUILD_COMMAND}

      ${EPA_EXTRA_ARGUMENTS}

      LOG_DOWNLOAD 1
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
    )
  endif(NOT LIBNAME_FOUND)
endfunction(ExternalProjectAutotools)
