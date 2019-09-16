include_guard(GLOBAL)

ExternalProjectCMake(freetype
  DEPENDS zlib
  URL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.xz
  URL_HASH SHA256=16dbfa488a21fe827dc27eaf708f42f7aa3bb997d745d31a19781628c36ba26f

  # Freetype needs some "patching" after the install for Cairo to pick it up properly.
  # All three patched documented in the script.
  EXTRA_ARGUMENTS
    TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixFreetypeInstall.sh ${THIRDPARTY_PREFIX}
    LOG_TEST 1
)
