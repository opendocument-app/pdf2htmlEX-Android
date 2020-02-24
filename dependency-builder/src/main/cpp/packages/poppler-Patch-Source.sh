#!/bin/sh
set -eu
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

patch $1/CMakeLists.txt <$BASEDIR/poppler-Patch-Source-use-fontconfig.patch
patch $1/CMakeLists.txt <$BASEDIR/poppler-Patch-Source-trim-whitespace-from-libs.patch

