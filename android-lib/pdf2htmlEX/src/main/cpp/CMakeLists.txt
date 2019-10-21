cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
project(pdf2htmlEX-android)

get_filename_component(ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../.." ABSOLUTE)

SET(PKG_CONFIG_EXECUTABLE ${ROOT_DIR}/build/${CMAKE_BUILD_TYPE}/${ANDROID_ABI}/bin/pkg-config)

include(FindPkgConfig)
pkg_search_module(pdf2htmlEX REQUIRED pdf2htmlEX)

link_directories(${pdf2htmlEX_LIBRARY_DIRS})

add_library(pdf2htmlEX-android SHARED pdf2htmlEX.cc)

target_link_libraries(pdf2htmlEX-android
  ${CMAKE_CURRENT_LIST_DIR}/../../../build/tmpfile/jni/${ANDROID_ABI}/libtmpfile.so
  ${pdf2htmlEX_LIBRARIES}
)

set_target_properties(pdf2htmlEX-android PROPERTIES COMPILE_FLAGS ${pdf2htmlEX_CFLAGS})
target_include_directories(pdf2htmlEX-android PRIVATE ${pdf2htmlEX_INCLUDE_DIRS})

