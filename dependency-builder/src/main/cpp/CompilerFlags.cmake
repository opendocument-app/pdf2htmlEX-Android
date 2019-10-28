# CompilerFlags.cmake
#
# pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
# Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
#
# Copyright (c) 2019 Vilius Sutkus <ViliusSutkus89@gmail.com>
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

# Autotools and Meson need toolchain info
# This file defines that info

# Process CFLAGS, CXXFLAGS and LDFLAGS

# CMAKE_C_FLAGS and CMAKE_CXX_FLAGS will by used by Autotools, CMake and Meson

# Android toolchain adds debugging symbols even in MinSizeRel, but strips them when packaging APK.
# APK is not necessary in this use case, just strip -g
if(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
  STRING(REPLACE "-g" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
  STRING(REPLACE "-g" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()

# CFLAGS , CXXFLAGS and LDFLAGS will by used by Autotools and Meson

SET(CFLAGS ${CMAKE_C_FLAGS})
SET(CXXFLAGS ${CMAKE_CXX_FLAGS})
SET(LDFLAGS ${ANDROID_LINKER_FLAGS})

if (CMAKE_BUILD_TYPE STREQUAL Debug)
  STRING(APPEND CFLAGS ${CMAKE_C_FLAGS_DEBUG})
  STRING(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_DEBUG})
elseif(CMAKE_BUILD_TYPE STREQUAL Release)
  STRING(APPEND CFLAGS ${CMAKE_C_FLAGS_RELEASE})
  STRING(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_RELEASE})
elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
  STRING(APPEND CFLAGS ${CMAKE_C_FLAGS_RELWITHDEBINFO})
  STRING(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
elseif(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
  STRING(APPEND CFLAGS ${CMAKE_C_FLAGS_MINSIZEREL})
  STRING(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_MINSIZEREL})
endif()

STRING(APPEND CFLAGS " -I${THIRDPARTY_PREFIX}/include")
STRING(APPEND CXXFLAGS " -I${THIRDPARTY_PREFIX}/include")
STRING(APPEND LDFLAGS " -L${THIRDPARTY_PREFIX}/lib")

# Linking shared shared libs against static libs require static libs to have
# Position Independent Code (PIC)
# libpdf2htmlEX.so is a shared lib
STRING(APPEND CFLAGS " -fPIC ")
STRING(APPEND CXXLAGS " -fPIC ")

# march=armv7-a breaks build.
# Both Autotools and Meson fail, telling that compiler does not work
if(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
  STRING(REPLACE "-march=armv7-a" "" CFLAGS "${CFLAGS}")
  STRING(REPLACE "-march=armv7-a" "" CXXFLAGS "${CXXFLAGS}")
endif()

