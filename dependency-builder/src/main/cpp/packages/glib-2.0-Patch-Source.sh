#!/bin/sh
set -euo pipefail

MESON_BUILD_FILE=$1/meson.build

# iconv and intl patches not needed anymore
#sed -i "s/cc.find_library('iconv')/dependency('iconv')/g" $MESON_BUILD_FILE
#sed -i "s/cc.find_library('intl'/dependency('intl'/g" $MESON_BUILD_FILE

if test "$ANDROID_NATIVE_API_LEVEL" -lt "21"
then
  echo "Patching $MESON_BUILD_FILE to not use stpcpy. Meson detects it, however it is not avail."
  sed -i "s/glib_conf.set('HAVE_STPCPY', 1)/#glib_conf.set('HAVE_STPCPY', 1)/g" $MESON_BUILD_FILE
fi

