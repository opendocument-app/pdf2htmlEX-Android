#!/bin/sh
set -eu

# Force linking against libjpeg when linking against libtiff
sed -i 's/${TIFF_LIBNAME}/${TIFF_LIBNAME} ${CMAKE_INSTALL_PREFIX}\/lib\/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX}/g' $1/src/bin/jp2/CMakeLists.txt

