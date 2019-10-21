#!/bin/sh
set -euo pipefail

THIRDPARTY_PREFIX=$2
PC_FILE=$THIRDPARTY_PREFIX/lib/pkgconfig/libfontforge.pc

# Fontforge uses libxml-2.0 gio-2.0
# But does not declare them in libfontforge.pc
sed -i "s/Requires\.private\:/Requires\.private\: libxml-2.0 gio-2.0/g" $PC_FILE

# Check if sed succeeded (in case there is no Requires.private line)
grep "libxml" $PC_FILE --quiet

