include_guard(GLOBAL)

ExternalProjectMeson(libintl
  URL https://github.com/frida/proxy-libintl/archive/0.1.tar.gz
  URL_HASH SHA256=202d90855943091b11ac91863ff5884f0eaf80318a32dc8504fcfdafc65992ed

  EXTRA_ARGUMENTS
  # Delete libintl.so.
  TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixLibintlInstall.sh ${THIRDPARTY_PREFIX}
  LOG_TEST 1
)
