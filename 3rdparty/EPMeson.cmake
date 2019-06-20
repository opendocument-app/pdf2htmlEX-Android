include(CompilerFlags.cmake)

if (ANDROID)
  if(ANDROID_ABI STREQUAL armeabi-v7a)
    SET(MESON_SYSTEM "android-arm")
    SET(MESON_CPU_FAMILY "arm")
    SET(MESON_CPU "armv7-a")
  elseif(ANDROID_ABI STREQUAL arm64-v8a)
    SET(MESON_SYSTEM "android-aarch64")
    SET(MESON_CPU_FAMILY "aarch64")
    SET(MESON_CPU "aarch64")
  elseif(ANDROID_ABI STREQUAL x86)
    SET(MESON_SYSTEM "android-x86")
    SET(MESON_CPU_FAMILY "x86")
    SET(MESON_CPU "i686")
  elseif(ANDROID_ABI STREQUAL x86_64)
    SET(MESON_SYSTEM "android-x86_64")
    SET(MESON_CPU_FAMILY "x86_64")
    SET(MESON_CPU "x86_64")
  else()
    message(FATAL_ERROR "Invalid Android ABI: ${ANDROID_ABI}.")
  endif()
  set(MESON_ENDIAN "little")

  SET(MESON_CC ${CC})
  SET(MESON_CPP ${CXX})
  SET(MESON_LLVM-CONFIG ${ANDROID_TOOLCHAIN_ROOT}/bin/llvm-config)
  SET(MESON_CROSS_COMPILE_FILE ${THIRDPARTY_PREFIX}/meson_cross_file.txt)
endif()

# Provide a meson cross compile file
if (MESON_CROSS_COMPILE_FILE AND NOT EXISTS ${MESON_CROSS_COMPILE_FILE})
  configure_file(${CMAKE_CURRENT_LIST_DIR}/meson_cross_file.txt.in ${MESON_CROSS_COMPILE_FILE} @ONLY)
endif()

function(ExternalProjectMeson EXTERNAL_PROJECT_NAME)
  pkg_check_modules(LIBNAME QUIET ${EXTERNAL_PROJECT_NAME})
  if (NOT LIBNAME_FOUND)
    message("External project ${EXTERNAL_PROJECT_NAME} not found, will have to be built.")

    set(options PKG_CONFIG_FORCE_STATIC)
    set(oneValueArgs URL URL_HASH)
    set(multipleValueArgs DEPENDS CONFIGURE_ARGUMENTS EXTRA_ARGUMENTS)
    cmake_parse_arguments(EPM "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    if (EPM_PKG_CONFIG_FORCE_STATIC)
      message(FATAL_ERROR "PKG_CONFIG_FORCE_STATIC NOT IMPLEMENTED FOR ExternalProjectMeson!")
    endif (EPM_PKG_CONFIG_FORCE_STATIC)

    CheckIfTarballCachedLocally(EPM_URL)

    FilterDependsList(EPM_DEPENDS)

    if (CMAKE_BUILD_TYPE STREQUAL Debug)
      set(MESON_BUILD_TYPE debug)
    elseif(CMAKE_BUILD_TYPE STREQUAL Release)
      set(MESON_BUILD_TYPE release)
    elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
      set(MESON_BUILD_TYPE debugoptimized)
    elseif(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
      set(MESON_BUILD_TYPE minsize)
    else()
      message(FATAL_ERROR "Unknown build type:" ${CMAKE_BUILD_TYPE})
    endif()

    SET(MESON_ENV
      # https://github.com/mesonbuild/meson/issues/217
      # find_library is now cc.find_library and now uses the linker to check if a particular library is available (similar to how AC_CHECK_LIB does it). This means you can set the LIBRARY_PATH env variable (when using gcc/clang and the LIBPATH env variable when using MSVC) to point to your "library providing" root. It also accepts a colon-separated list of directories. This is how almost everyone does non-default-linker-search-path library searching and linking.
      LIBRARY_PATH=${THIRDPARTY_PREFIX}/lib
      LIBPATH=${THIRDPARTY_PREFIX}/lib

      # http://mesonbuild.com/Reference-manual.html#compiler-object
      # Note that if you have a single prefix with all your dependencies, you might find it easier to append to the environment variables C_INCLUDE_PATH with GCC/Clang and INCLUDE with MSVC to expand the default include path, and LIBRARY_PATH with GCC/Clang and LIB with MSVC to expand the default library search path.
      C_INCLUDE_PATH=${THIRDPARTY_PREFIX}/include
      INCLUDE=${THIRDPARTY_PREFIX}/include

      CFLAGS=${CFLAGS}
      CPPFLAGS=${CXXFLAGS}
      LDFLAGS=${LDFLAGS}
    )

    set(EPM_CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${MESON_ENV}
      meson --buildtype ${MESON_BUILD_TYPE}
      ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME}
      ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME}-build
    )

    if(MESON_CROSS_COMPILE_FILE)
      LIST(APPEND EPM_CONFIGURE_COMMAND --cross-file ${MESON_CROSS_COMPILE_FILE})
    endif(MESON_CROSS_COMPILE_FILE)
    
    if (NOT BUILD_SHARED_LIBS)
      LIST(APPEND EPM_CONFIGURE_COMMAND -Ddefault_library=static)
    endif (NOT BUILD_SHARED_LIBS)

    SET(NINJA_WRAPPER ${CMAKE_COMMAND} -E env ${MESON_ENV}
      ninja -C ${CMAKE_CURRENT_BINARY_DIR}/${EXTERNAL_PROJECT_NAME}-prefix/src/${EXTERNAL_PROJECT_NAME}-build)

    ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
      ${EPM_DEPENDS}
      URL ${EPM_URL}
      URL_HASH ${EPM_URL_HASH}

      CONFIGURE_COMMAND ${EPM_CONFIGURE_COMMAND} ${EPM_CONFIGURE_ARGUMENTS}
      BUILD_COMMAND ${NINJA_WRAPPER}
      INSTALL_COMMAND ${NINJA_WRAPPER} install

      ${EPM_EXTRA_ARGUMENTS}

      LOG_DOWNLOAD 1
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
    )
  endif(NOT LIBNAME_FOUND)
endfunction(ExternalProjectMeson EXTERNAL_PROJECT_NAME)
