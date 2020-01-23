#!/bin/sh
set -eu

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

# pdf2htmlEX provides a binary executable.
# pdf2htmlEX-Android needs a library.
patch -p0 <$BASEDIR/pdf2htmlEX-Patch-Source-make-a-library.patch

# Check for package cairo-svg, not for cairo, which could have svg headers.
patch $1/CMakeLists.txt <$BASEDIR/pdf2htmlEX-Patch-Source-find-cairo-svg.patch

# Do not add additional compile flags
patch $1/CMakeLists.txt <$BASEDIR/pdf2htmlEX-Patch-Source-cflags.patch

