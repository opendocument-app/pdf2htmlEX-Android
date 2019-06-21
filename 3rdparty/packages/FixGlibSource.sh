#!/usr/bin/env bash
set -euo pipefail
SRC=$1/meson.build
THIRDPARTY_LIBDIR=$2/lib
THIRDPARTY_LIBDIR_SLASH_ESCAPED="${THIRDPARTY_LIBDIR//\//\\\/}\/"

ANDROID_ABI_LEVEL=$3

echo "Before patching: "
grep "find_library('iconv'" $SRC
sed -i "s/find_library('iconv')/find_library('iconv', dirs: '${THIRDPARTY_LIBDIR_SLASH_ESCAPED}')/g" $SRC

echo ""
echo "After patching: "
grep "find_library('iconv'" $SRC


if [ "${ANDROID_ABI_LEVEL}" -lt "21" ]; then
  echo "Patching $SRC to not use stpcpy. Meson detects it, however it is not avail."
  sed -i "s/glib_conf.set('HAVE_STPCPY', 1)/#glib_conf.set('HAVE_STPCPY', 1)/g" $SRC
fi
