function(IncludePackageIfExists PACKAGE_NAME)
  SET(PACKAGE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/packages/${PACKAGE_NAME}.cmake)
  if(EXISTS ${PACKAGE_FILE})
    include(${PACKAGE_FILE})
  endif()
endfunction(IncludePackageIfExists)

# DEPEND only on those ExternalProjects that we can actually find as targets
# No target? Check for pkg-config
# Not found? Error!
function(FilterDependsList DEPENDS_LIST)
  # Expand DEPENDS_LIST variable twice, to get the INPUT value
  SET(INPUT ${${DEPENDS_LIST}})
  SET(RESULT)

  if(INPUT)
    foreach(DEPENDEE IN ITEMS ${INPUT})
      # Check if we have a package file for this depends
      # IncludePackageIfExists(${DEPENDEE})
      SET(PACKAGE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/packages/${DEPENDEE}.cmake)
      if(EXISTS ${PACKAGE_FILE})
        include(${CMAKE_CURRENT_SOURCE_DIR}/packages/${DEPENDEE}.cmake) #OPTIONAL
      endif()

      if (TARGET ${DEPENDEE})
        message(STATUS "${DEPENDEE} found as a target")
        list(APPEND RESULT ${DEPENDEE})
      # Hardcoded skip for iconv, because it does not have pkg-config.pc
      # If iconv target not found, just assume it's either built already or not needed due to ANDROID-28+
      elseif(NOT "${DEPENDEE}" STREQUAL "iconv")
        pkg_check_modules(LIBNAME REQUIRED ${DEPENDEE})
      endif()
    endforeach(DEPENDEE IN ITEMS ${INPUT})

    if (RESULT)
      SET(RESULT DEPENDS ${RESULT})
    endif(RESULT)
  endif(INPUT)

  SET(${DEPENDS_LIST} ${RESULT} PARENT_SCOPE)
endfunction(FilterDependsList)
