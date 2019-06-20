include_guard(GLOBAL)

# We do not build zlib, only provide pkg-config.pc file, so that the library could be found easier.
if (NOT EXISTS ${THIRDPARTY_PKG_CONFIG_LIBDIR}/zlib.pc)
  configure_file(${CMAKE_CURRENT_LIST_DIR}/zlib.pc.in ${THIRDPARTY_PKG_CONFIG_LIBDIR}/zlib.pc @ONLY)
endif()
