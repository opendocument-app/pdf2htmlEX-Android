#!/bin/sh
set -euo pipefail
THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

POPPLER_SRC=$1
CMAKELISTS=$POPPLER_SRC/CMakeLists.txt
THIRDPARTY_PREFIX=$2

# Tiff-4 dependencies are not included
TIFF_LIBS=`$THIRDPARTY_PREFIX/bin/pkg-config --libs libtiff-4`
sed -i "/macro_optional_find_package(TIFF)/a if(TIFF_FOUND)\n SET(TIFF_LIBRARIES \"$TIFF_LIBS\")\nendif()" $CMAKELISTS

# Cairo dependencies are not included
CAIRO_LIBS=`$THIRDPARTY_PREFIX/bin/pkg-config --libs cairo`
sed -i "/set(poppler_LIBS \${FREETYPE_LIBRARIES})/a if(CAIRO_FOUND)\n set(poppler_LIBS \${poppler_LIBS} $CAIRO_LIBS)\nendif()" $CMAKELISTS

# https://gitlab.freedesktop.org/poppler/poppler/commit/842a75d8d6cc0105da6c0b5dbb0997b79ba63246
# Poppler-0.74.0 fixed HAVE_FSEEKO detection issue that happens prior to Android-24
# Patch that file until we upgrade to Poppler-0.74.0+
patch $POPPLER_SRC/ConfigureChecks.cmake < ${BASEDIR}/poppler-Patch-Source-android-23.patch

