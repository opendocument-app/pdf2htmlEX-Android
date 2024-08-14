# CMakeLists.txt
#
# pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
# Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
#
# Copyright (c) 2019, 2020, 2024 Vilius Sutkus ViliusSutkus89.com
#
# pdf2htmlEX-Android is free software: you can redistribute it and/or modify
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

cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
set(CMAKE_BUILD_TYPE Release CACHE STRING "Build configuration (Debug, Release, RelWithDebInfo, MinSizeRel)")
project(pdf2htmlEX-android)

find_package(pdf2htmlEX REQUIRED CONFIG)

add_subdirectory(src/main/cpp)

FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/build/assets")
function(copy_assets sourcevar dstsubdir)
  if(DEFINED "${sourcevar}")
    FILE(REMOVE_RECURSE "${CMAKE_CURRENT_LIST_DIR}/build/assets/${dstsubdir}")
    FILE(CREATE_LINK "${${sourcevar}}" "${CMAKE_CURRENT_LIST_DIR}/build/assets/${dstsubdir}" COPY_ON_ERROR SYMBOLIC)
  endif()
endfunction()

copy_assets("PDF2HTMLEX_RES_DIR" "pdf2htmlEX")
copy_assets("POPPLER_DATA_RES_DIR" "poppler-data")
copy_assets("FONTCONFIG_RES_DIR" "fontconfig")

#@TODO: fontforge cidfiles
