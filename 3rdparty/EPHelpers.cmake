# DEPEND only on those ExternalProjects that we can actually find as targets
# No target? Check for pkg-config
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
        message(STATUS "${DEPENDENCY} found as a target")
        list(APPEND RESULT ${DEPENDENCY})

      elseif("${DEPENDENCY}" STREQUAL "iconv")
        # iconv does not have pkg-config.pc. Just check if the it exists.
        # ANDROID-28+ has it built in, no need.
        if (NOT (ANDROID_NATIVE_API_LEVEL GREATER_EQUAL 28))
          if (NOT EXISTS ${THIRDPARTY_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}iconv${CMAKE_STATIC_LIBRARY_SUFFIX})
            message(FATAL_ERROR "Missing dependency ${DEPENDENCY}!")
          endif()
        endif()

      else()
        pkg_check_modules(LIBNAME REQUIRED ${DEPENDENCY})
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

  SET(CACHED_FILENAME ${TARBALL_STORAGE}${FILENAME})
  if (EXISTS ${TARBALL_STORAGE}${FILENAME})
    SET(${URL} ${TARBALL_STORAGE}${FILENAME} PARENT_SCOPE)
  endif()

endfunction(CheckIfTarballCachedLocally)
