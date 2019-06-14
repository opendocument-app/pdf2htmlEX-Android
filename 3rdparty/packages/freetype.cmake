include_guard(GLOBAL)

ExternalProjectCMake(freetype
  DEPENDS zlib
  URL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.bz2
  #URL ${TARBALL_STORAGE}/freetype-2.10.0.tar.bz2
  URL_HASH SHA256=fccc62928c65192fff6c98847233b28eb7ce05f12d2fea3f6cc90e8b4e5fbe06

  # Freetype needs some "patching" after the install for Cairo to pick it up properly.
  # All three patched documented in /3rdparty/FixFreetypeInstall.sh
  EXTRA_ARGUMENTS
    TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixFreetypeInstall.sh ${THIRDPARTY_PREFIX}
    LOG_TEST 1
)
