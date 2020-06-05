# CMakeLists.txt
#
# pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
# Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
#
# Copyright (c) 2019, 2020 Vilius Sutkus <ViliusSutkus89@gmail.com>
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

cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
set(CMAKE_BUILD_TYPE Release CACHE STRING "Build configuration (Debug, Release, RelWithDebInfo, MinSizeRel)")

project(pdf2htmlEX-android)

get_filename_component(GIT_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../.." ABSOLUTE)
SET(PKG_CONFIG_EXECUTABLE ${GIT_ROOT_DIR}/dependency-builder/build/installed/${CMAKE_BUILD_TYPE}/${ANDROID_ABI}/bin/pkg-config)

include(FindPkgConfig)
pkg_search_module(pdf2htmlEX REQUIRED pdf2htmlEX)

link_directories(${pdf2htmlEX_LIBRARY_DIRS})

add_library(pdf2htmlEX-android SHARED pdf2htmlEX.cc)

find_library(log-lib log)

target_link_libraries(pdf2htmlEX-android
  ${pdf2htmlEX_LIBRARIES}
  tmpfile
  ${log-lib}
)

STRING(REPLACE ";" " " pdf2htmlEX_CFLAGS_STR "${pdf2htmlEX_CFLAGS}")
set_target_properties(pdf2htmlEX-android PROPERTIES COMPILE_FLAGS ${pdf2htmlEX_CFLAGS_STR})
target_include_directories(pdf2htmlEX-android PRIVATE ${pdf2htmlEX_INCLUDE_DIRS})
