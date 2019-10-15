cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)

project(pdf2htmlEX-android)

add_library(pdf2htmlEX-android SHARED pdf2htmlEX.cc)

# Link against android log library
find_library(log-lib log)
target_link_libraries(pdf2htmlEX-android ${log-lib})

add_subdirectory(
  ${CMAKE_CURRENT_LIST_DIR}/../../../../../
  ${CMAKE_CURRENT_BINARY_DIR}/deps/
  )

# Depend on pdf2htmlEX target, which builds ExternalProject
# There is no target if that ExternalProject is already built
if (TARGET pdf2htmlEX)
  add_dependencies(pdf2htmlEX-android pdf2htmlEX)
endif()

#@TODO: maybe rename THIRDPARTY_PREFIX to INSTALLED_PREFIX or something?
SET(THIRDPARTY_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../build/${CMAKE_BUILD_TYPE}/${ANDROID_ABI})
SET(PKG_CONFIG_EXECUTABLE ${THIRDPARTY_PREFIX}/bin/pkg-config)

find_package(PkgConfig)

# Must be a different name than any Target in the current scope.
# find_package does not allow renaming,
# that is why pkg-config is needed to consume previously built pdf2htmlEX
pkg_search_module(pdf2htmlEX-imported REQUIRED pdf2htmlEX)

target_link_libraries(pdf2htmlEX-android ${pdf2htmlEX-imported_LIBRARIES})
target_include_directories(pdf2htmlEX-android PRIVATE ${pdf2htmlEX-imported_INCLUDE_DIRS})

