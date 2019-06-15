include_guard(GLOBAL)

IF (BUILD_ALL_3RDPARTY_UTILS_TO_CHECK_FOR_MISSING_SYMBOLS_IN_INCLUDED_LIBRARIES)
  SET(FONTFORGE_CONFIGURE_ARGUMENTS --enable-programs)
ELSE()
  SET(FONTFORGE_CONFIGURE_ARGUMENTS --disable-programs)
ENDIF ()

ExternalProjectAutotools(libfontforge
  DEPENDS libxml-2.0 libjpeg glib-2.0 freetype

  URL https://github.com/fontforge/fontforge/releases/download/20190413/fontforge-20190413.tar.gz
  URL_HASH SHA256=6762a045aba3d6ff1a7b856ae2e1e900a08a8925ccac5ebf24de91692b206617
  CONFIGURE_ARGUMENTS ${FONTFORGE_CONFIGURE_ARGUMENTS}

    # libfontforge check for TIFFRewriteField , which was deprecated in libtiff-4
    # http://www.simplesystems.org/libtiff/v4.0.0.html
    --without-libtiff
    # without cairo too, because of the same libtiff error
    --without-cairo

    # fontforge does not pick up libpng too
    --without-libpng

  # Fontforge uses libxml-2.0 gio-2.0
  # But does not declare them in libfontforge.pc
  # Fix after install
  EXTRA_ARGUMENTS
    TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixFontforgeInstall.sh ${THIRDPARTY_PREFIX}
    LOG_TEST 1

  ${FONTFORGE_STATIC}
)
