cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)

project(pdf2htmlEX-android)

add_library(pdf2htmlex-android SHARED pdf2htmlEX.cc)

# Link against android log library
find_library(log-lib log)
target_link_libraries(pdf2htmlex-android ${log-lib})

add_subdirectory(
  ${CMAKE_CURRENT_LIST_DIR}/../../../../../
  ${CMAKE_CURRENT_BINARY_DIR}/deps/
  )

add_dependencies(pdf2htmlex-android pdf2htmlEX)

