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

function(ExternalProjectCMake EXTERNAL_PROJECT_NAME)
  # Check both pkg-config and find-cmake
  find_package(${EXTERNAL_PROJECT_NAME} QUIET)
  pkg_check_modules(LIBNAME QUIET ${EXTERNAL_PROJECT_NAME})

  if (NOT ${EXTERNAL_PROJECT_NAME}_FOUND AND NOT LIBNAME_FOUND)
    message(STATUS "External project ${EXTERNAL_PROJECT_NAME} not found, will have to be built.")

    set(options)
    set(oneValueArgs URL URL_HASH)
    set(multipleValueArgs DEPENDS CONFIGURE_ARGUMENTS EXTRA_ARGUMENTS)
    cmake_parse_arguments(EPCM "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    CheckIfTarballCachedLocally(EPCM_URL)

    FilterDependsList(EPCM_DEPENDS)

    GetCMakeArguments("EPCM_CMAKE_ARGUMENTS"
      FORCED_ARGUMENTS "CMAKE_TOOLCHAIN_FILE" "CMAKE_VERBOSE_MAKEFILE" "CMAKE_BUILD_TYPE"
      IGNORED_ARGUMENTS "CMAKE_LIBRARY_OUTPUT_DIRECTORY")

    if (NOT BUILD_SHARED_LIBS)
      SET(SHARED_LIBS_ARGUMENT -DBUILD_SHARED_LIBS=OFF)
    endif (NOT BUILD_SHARED_LIBS)

    MESSAGE(STATUS "ExternalProjectCMake_ADD ${EXTERNAL_PROJECT_NAME}")
    ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
      ${EPCM_DEPENDS}
      URL ${EPCM_URL}
      URL_HASH ${EPCM_URL_HASH}

      CMAKE_ARGS ${EPCM_CMAKE_ARGUMENTS}
        -DCMAKE_PREFIX_PATH=${THIRDPARTY_PREFIX}
        -DCMAKE_INSTALL_PREFIX=${THIRDPARTY_PREFIX}
        -DCMAKE_FIND_ROOT_PATH=${THIRDPARTY_PREFIX}
        -DPKG_CONFIG_LIBDIR=${THIRDPARTY_PKG_CONFIG_LIBDIR}
        -DPKG_CONFIG_EXECUTABLE=${THIRDPARTY_PKG_CONFIG_EXECUTABLE}
        ${SHARED_LIBS_ARGUMENT}
        ${EPCM_CONFIGURE_ARGUMENTS}

      ${EPCM_EXTRA_ARGUMENTS}

      LOG_DOWNLOAD 1
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
    )
  endif(NOT ${EXTERNAL_PROJECT_NAME}_FOUND AND NOT LIBNAME_FOUND)
endfunction(ExternalProjectCMake)