#!/bin/sh
set -eu

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

cp $1/CMakeLists.txt $1/CMakeLists.txt.orig
cp $1/src/pdf2htmlEX.cc $1/src/pdf2htmlEX.cc.orig

# pdf2htmlEX provides a binary executable.
# pdf2htmlEX-Android needs a library.
# @TODO: retVal in EXE,
patch -p0 <$BASEDIR/pdf2htmlEX-Patch-Source-make-a-library.patch

patch -p0 <$BASEDIR/pdf2htmlEX-Patch-Source-prepare-exe-for-android.patch

# Check for package cairo-svg, not for cairo, which could have svg headers.
patch $1/CMakeLists.txt <$BASEDIR/pdf2htmlEX-Patch-Source-find-cairo-svg.patch

# Do not add additional compile flags
patch $1/CMakeLists.txt <$BASEDIR/pdf2htmlEX-Patch-Source-cflags.patch

