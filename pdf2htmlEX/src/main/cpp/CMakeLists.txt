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

add_library(envvar SHARED EnvVar.c)
add_library(pdf2htmlEX-android SHARED pdf2htmlEX.cc CCharGC.h)

find_library(log-lib log)
find_package(tmpfile REQUIRED CONFIG)
find_package(pdf2htmlEX REQUIRED CONFIG)

target_link_libraries(pdf2htmlEX-android
  pdf2htmlEX::pdf2htmlEX
  envvar
  tmpfile::tmpfile
  ${log-lib}
)
