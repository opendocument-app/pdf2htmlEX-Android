# CompilerBinaries.cmake
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

if (ANDROID)
  if(ANDROID_ABI STREQUAL armeabi-v7a)
    SET(AS ${ANDROID_TOOLCHAIN_ROOT}/bin/armv7a-linux-androideabi-as)
    SET(CC ${ANDROID_TOOLCHAIN_ROOT}/bin/armv7a-linux-androideabi${ANDROID_NATIVE_API_LEVEL}-clang)
    SET(CXX ${ANDROID_TOOLCHAIN_ROOT}/bin/armv7a-linux-androideabi${ANDROID_NATIVE_API_LEVEL}-clang++)
    SET(HOST_TRIPLE armv7a-linux-androideabi)
  elseif(ANDROID_ABI STREQUAL arm64-v8a)
    SET(AS ${ANDROID_TOOLCHAIN_ROOT}/bin/aarch64-linux-android-as)
    SET(CC ${ANDROID_TOOLCHAIN_ROOT}/bin/aarch64-linux-android${ANDROID_NATIVE_API_LEVEL}-clang)
    SET(CXX ${ANDROID_TOOLCHAIN_ROOT}/bin/aarch64-linux-android${ANDROID_NATIVE_API_LEVEL}-clang++)
    SET(HOST_TRIPLE aarch64-linux-android)
  elseif(ANDROID_ABI STREQUAL x86)
    SET(AS ${ANDROID_TOOLCHAIN_ROOT}/bin/x86-linux-android-as)
    SET(CC ${ANDROID_TOOLCHAIN_ROOT}/bin/i686-linux-android${ANDROID_NATIVE_API_LEVEL}-clang)
    SET(CXX ${ANDROID_TOOLCHAIN_ROOT}/bin/i686-linux-android${ANDROID_NATIVE_API_LEVEL}-clang++)
    SET(HOST_TRIPLE i686-linux-android)
  elseif(ANDROID_ABI STREQUAL x86_64)
    SET(AS ${ANDROID_TOOLCHAIN_ROOT}/bin/x86_64-linux-android-as)
    SET(CC ${ANDROID_TOOLCHAIN_ROOT}/bin/x86_64-linux-android${ANDROID_NATIVE_API_LEVEL}-clang)
    SET(CXX ${ANDROID_TOOLCHAIN_ROOT}/bin/x86_64-linux-android${ANDROID_NATIVE_API_LEVEL}-clang++)
    SET(HOST_TRIPLE x86_64-linux-android)
  else()
    message(FATAL_ERROR "Invalid Android ABI: ${ANDROID_ABI}.")
  endif()
else()
  #SET(AS @TODO: set AS binary)
  # CMAKE_ASM_COMPILER??
  SET(CC ${CMAKE_C_COMPILER})
  SET(CXX ${CMAKE_CXX_COMPILER})
endif()
