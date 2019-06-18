#!/bin/bash
set -euo pipefail

THIRDPARTY_PREFIX=$1
THIRDPARTY_PKG_CONFIG_LIBDIR=${THIRDPARTY_PREFIX}/lib/pkgconfig

# Libtiff, when built with CMake doesn't include
# Requires.private: libjpeg
# Libs.private: -lm
# in libtiff-4.pc

# Libs.private may or may not be empty, modify line with sed
sed -i "s/Libs\.private\:/Libs\.private\: \-lm/g" ${THIRDPARTY_PKG_CONFIG_LIBDIR}/libtiff-4.pc

echo "Requires.private: libjpeg" >> ${THIRDPARTY_PKG_CONFIG_LIBDIR}/libtiff-4.pc
