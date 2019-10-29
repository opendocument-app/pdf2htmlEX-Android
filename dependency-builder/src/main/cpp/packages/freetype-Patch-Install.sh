#!/bin/sh
set -eu

THIRDPARTY_PREFIX=$2
THIRDPARTY_PKG_CONFIG_LIBDIR=$THIRDPARTY_PREFIX/lib/pkgconfig

# From freetype2/docs/VERSIONS.txt
# release     libtool     so
# -------------------------------
#   2.10.1     23.1.17   6.17.1
# Cairo checks for libtool version, but pkg-config reports release version.
sed -i "s/Version\:\ 2.10.1/Version\:\ 23.1.17/g" $THIRDPARTY_PKG_CONFIG_LIBDIR/freetype2.pc

# Cairo's ./configure script is looking for freetype, not freetype2
cp -v $THIRDPARTY_PKG_CONFIG_LIBDIR/freetype2.pc $THIRDPARTY_PKG_CONFIG_LIBDIR/freetype.pc

# Cairo, like a normal project, links againts -lfreetype, because that's what's provided by freetype.pc
# In debug builds, freetype library filename is libfreetyped.a
if test -f "$THIRDPARTY_PREFIX/lib/libfreetyped.a"
then
  cp -v $THIRDPARTY_PREFIX/lib/libfreetyped.a $THIRDPARTY_PREFIX/lib/libfreetype.a
fi

