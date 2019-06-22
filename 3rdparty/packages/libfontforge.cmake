include_guard(GLOBAL)

IF (BUILD_3RDPARTY_BINARIES)
  SET(FONTFORGE_BUILD_PROGRAMS_ARGUMENT --enable-programs)
ELSE()
  SET(FONTFORGE_BUILD_PROGRAMS_ARGUMENT --disable-programs)
ENDIF ()

if (ANDROID)
  # Upstream fontforge builds only on Android-26+
  # Apply patches, if ANDROID is earlier than 26
  if (NOT ANDROID_NATIVE_API_LEVEL GREATER_EQUAL 26)
    SET(FONTFORGE_PATCH_FOR_ANDROID_BEFORE_26
      UPDATE_COMMAND
        ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixFontforgeSource.sh
        ${CMAKE_CURRENT_BINARY_DIR}/libfontforge-prefix/src/libfontforge/
      LOG_UPDATE 1
    )
  endif()

  # Android-23 fails to build scripting.c, which can be disabled by --disable-native-scripting .
  # Fontforgeexe fails to build too, without native scripting. Disable it too.
  if (NOT ANDROID_NATIVE_API_LEVEL GREATER_EQUAL 24)
    SET(FONTFORGE_BUILD_PROGRAMS_ARGUMENT --disable-native-scripting --disable-programs)
  endif()
endif()

ExternalProjectAutotools(libfontforge
  DEPENDS freetype glib-2.0 iconv libintl libjpeg libxml-2.0 zlib

  URL https://github.com/fontforge/fontforge/releases/download/20190413/fontforge-20190413.tar.gz
  URL_HASH SHA256=6762a045aba3d6ff1a7b856ae2e1e900a08a8925ccac5ebf24de91692b206617
  CONFIGURE_ARGUMENTS ${FONTFORGE_BUILD_PROGRAMS_ARGUMENT}

    # libfontforge checks for TIFFRewriteField , which was deprecated in libtiff-4
    # http://www.simplesystems.org/libtiff/v4.0.0.html
    --without-libtiff
    # without cairo too, because of the same libtiff error
    --without-cairo

    # fontforge does not pick up libpng too
    --without-libpng

  EXTRA_ARGUMENTS
    ${FONTFORGE_PATCH_FOR_ANDROID_BEFORE_26}

  # Fontforge uses libxml-2.0 gio-2.0
  # But does not declare them in libfontforge.pc
  # Fix after install
    TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixFontforgeInstall.sh ${THIRDPARTY_PREFIX}
    LOG_TEST 1

  ${FONTFORGE_STATIC}
)
