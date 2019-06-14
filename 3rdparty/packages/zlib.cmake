include_guard(GLOBAL)

# zlib is provided by NDK, but it doesn't have pkg-config .pc file.
# Easier to just build it.

# zlib doesn't handle BUILD_SHARED_LIBS=OFF.. manually remove .so, if needed
if (NOT BUILD_SHARED_LIBS)
  SET(ZLIB_DO_NOT_BUILD_SHARED_LIBS EXTRA_ARGUMENTS
    TEST_COMMAND rm -v ${THIRDPARTY_PREFIX}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}z${CMAKE_SHARED_LIBRARY_SUFFIX}
    LOG_TEST 1
  )
endif (NOT BUILD_SHARED_LIBS)

ExternalProjectCMake(zlib
  URL https://zlib.net/zlib-1.2.11.tar.gz
  #URL ${TARBALL_STORAGE}/zlib-1.2.11.tar.gz
  URL_HASH SHA256=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1
  # install pkg-config.pc to /lib, not /share
  CONFIGURE_ARGUMENTS -DINSTALL_PKGCONFIG_DIR=${THIRDPARTY_PKG_CONFIG_LIBDIR}
  ${ZLIB_DO_NOT_BUILD_SHARED_LIBS}
)
