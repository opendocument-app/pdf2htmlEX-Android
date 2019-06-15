#!/bin/bash
set -euo pipefail

THIRDPARTY_PREFIX=$1
PC_FILE=${THIRDPARTY_PREFIX}/lib/pkgconfig/glib-2.0.pc


echo "Before patching"
cat $PC_FILE

# glib uses libintl
# Currently, pkg-config.pc tells linker to first link libintl.a and only then libglib.a
# That is bad, because libintl.a is a static lib, and whatever symbols it provides will not
# be included when requested by the the libglib.a

sed -i 's/Libs: -lintl/Libs:/g' $PC_FILE
sed -i '/Libs:/s/$/ -lintl/' $PC_FILE

echo ""

echo "After patching"
cat $PC_FILE
