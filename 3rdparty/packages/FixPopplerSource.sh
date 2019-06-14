#!/bin/bash
set -euo pipefail
POPPLER_SRC=$1
CMAKELISTS=${POPPLER_SRC}CMakeLists.txt

echo "Fixing $CMAKELISTS"

# Poppler source fixing is a two part job

echo "Fixing TIFF package include"
# A) As described in libtiff-4.cmake
# Manually link against libjpeg in all packages, that link against libtiff.
sed -i '/macro_optional_find_package(TIFF)/a if(TIFF_FOUND)\n  SET(TIFF_LIBRARIES "${TIFF_LIBRARIES};${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX}")\nendif(TIFF_FOUND)' $CMAKELISTS
echo "grep -A 5 'macro_optional_find_package(TIFF)' $CMAKELISTS"
grep -A 5 'macro_optional_find_package(TIFF)' $CMAKELISTS

echo ""

echo "Fixing Cairo package include"
# B) Manually link against pixman-1.so (not .a, pixman does not build .a) if Cairo is used
# Poppler did not check Cairo's dependencies
sed -i '/macro_optional_find_package(Cairo ${CAIRO_VERSION})/a if(CAIRO_FOUND)\n  SET(TIFF_LIBRARIES "${TIFF_LIBRARIES};${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}pixman-1${CMAKE_SHARED_LIBRARY_SUFFIX}")\nendif(CAIRO_FOUND)' $CMAKELISTS
echo "grep -A 5 'macro_optional_find_package(Cairo \${CAIRO_VERSION})' $CMAKELISTS"
grep -A 5 'macro_optional_find_package(Cairo ${CAIRO_VERSION})' $CMAKELISTS
