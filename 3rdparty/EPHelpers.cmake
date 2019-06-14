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
      # Hardcoded skip for iconv, because it does not have pkg-config.pc
      # If iconv target not found, just assume it's either built already or not needed due to ANDROID-28+
      elseif(NOT "${DEPENDENCY}" STREQUAL "iconv")
        pkg_check_modules(LIBNAME REQUIRED ${DEPENDENCY})
      endif()
    endforeach(DEPENDENCY IN ITEMS ${INPUT})

    if (RESULT)
      SET(RESULT DEPENDS ${RESULT})
    endif(RESULT)
  endif(INPUT)

  SET(${DEPENDS_LIST} ${RESULT} PARENT_SCOPE)
endfunction(FilterDependsList)
