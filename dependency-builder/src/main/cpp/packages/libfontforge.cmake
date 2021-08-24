include_guard(GLOBAL)

IF (BUILD_3RDPARTY_BINARIES)
  SET(FONTFORGE_BUILD_PROGRAMS_ARGUMENT --enable-programs)
ELSE()
  SET(FONTFORGE_BUILD_PROGRAMS_ARGUMENT --disable-programs)
ENDIF ()

# libfontforge fails to pick up libpng on it's own.
# Errors out about not being able to find developer version of libpng.
# If libpng is not picked up, it fails to link against cairo too.
set(LIBPNG_CFLAGS "-I${THIRDPARTY_PREFIX}/include/libpng16")
set(LIBPNG_LIBS "-L${THIRDPARTY_PREFIX}/lib -lpng16 -lm -lz")
set(EXTRA_ENVVARS
  LIBPNG_CFLAGS=${LIBPNG_CFLAGS}
  LIBPNG_LIBS=${LIBPNG_LIBS}
)

ExternalProjectAutotools(libfontforge
  DEPENDS cairo freetype glib-2.0 iconv libjpeg libpng libtool libuninameslist libxml-2.0 pango zlib intl

  URL https://github.com/fontforge/fontforge/releases/download/20170731/fontforge-dist-20170731.tar.xz
  URL_HASH SHA256=840adefbedd1717e6b70b33ad1e7f2b116678fa6a3d52d45316793b9fd808822
  LICENSE_FILES LICENSE COPYING.gplv3

  EXTRA_ENVVARS ${EXTRA_ENVVARS}

  CONFIGURE_ARGUMENTS ${FONTFORGE_BUILD_PROGRAMS_ARGUMENT}

    # libfontforge checks for TIFFRewriteField , which was deprecated in libtiff-4
    # http://www.simplesystems.org/libtiff/v4.0.0.html
    --without-libtiff

    --with-cairo
    --with-libpng
)

