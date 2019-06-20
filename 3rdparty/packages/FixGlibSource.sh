#!/usr/bin/env bash
set -euo pipefail
SRC=$1/meson.build
THIRDPARTY_LIBDIR=$2/lib
THIRDPARTY_LIBDIR_SLASH_ESCAPED="${THIRDPARTY_LIBDIR//\//\\\/}\/"

echo "Before patching: "
grep "find_library('iconv'" $SRC
sed -i "s/find_library('iconv')/find_library('iconv', dirs: '${THIRDPARTY_LIBDIR_SLASH_ESCAPED}')/g" $SRC

echo ""
echo "After patching: "
grep "find_library('iconv'" $SRC
