#!/bin/bash
set -euo pipefail

THIRDPARTY_PREFIX=$1
PC_FILE=${THIRDPARTY_PREFIX}/lib/pkgconfig/libfontforge.pc

# Fontforge uses libxml-2.0 gio-2.0
# But does not declare them in libfontforge.pc

echo "Before patching"
cat $PC_FILE

sed -i "s/Requires\.private\:/Requires\.private\: libxml-2.0 gio-2.0 /g" $PC_FILE

echo ""
echo "After patching"
cat $PC_FILE
