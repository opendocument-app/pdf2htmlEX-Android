#!/bin/sh
set -eu

THIRDPARTY_PREFIX=$2
PC_FILE=$THIRDPARTY_PREFIX/lib/pkgconfig/poppler.pc

# Poppler uses libopenjp2 and lcms2
# But does not declare them in poppler.pc
echo "Requires.private: libopenjp2 lcms2 libtiff-4 freetype" >> $PC_FILE

# Check if sed succeeded (in case there is no Requires.private line)
grep "lcms2" $PC_FILE --quiet

