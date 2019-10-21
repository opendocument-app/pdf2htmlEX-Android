#!/bin/bash
set -euo pipefail

PIXMAN_SRC=$1

# Pixman only builds shared libraries.
# lrwxrwxrwx 1 vilius vilius   16 Jun 15 14:13 libpixman-1.so -> libpixman-1.so.0
# lrwxrwxrwx 1 vilius vilius   21 Jun 15 14:13 libpixman-1.so.0 -> libpixman-1.so.0.38.4
# -rwxr-xr-x 1 vilius vilius 6.7M Jun 15 14:13 libpixman-1.so.0.38.4

# We want a static library

MESON_BUILD=$PIXMAN_SRC/pixman/meson.build

echo "Before patching: "
grep 'libpixman = ' $MESON_BUILD -A 7

# Force linking against libjpeg when linking against libtiff
sed -i 's/libpixman = shared_library/libpixman = static_library/g' $MESON_BUILD

echo ""

echo "After patching: "
grep 'libpixman = ' $MESON_BUILD -A 7

echo ""

# simd static libraries need to be installed to.
# Previously they were just included in the .so

echo "Before patching: "
grep 'pixman_simd_libs +' $MESON_BUILD -B 3 -A 4

sed -i "/\[name + '.c', config_h, version_h, simd\[3\]\],/a\ \ \ \ \ \ install : true," $MESON_BUILD
echo ""

echo "After patching: "
grep 'pixman_simd_libs +' $MESON_BUILD -B 3 -A 5
