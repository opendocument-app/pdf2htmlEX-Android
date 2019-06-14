#!/bin/bash
set -euo pipefail

THIRDPARTY_PREFIX=$1
PC_FILE=${THIRDPARTY_PREFIX}/lib/pkgconfig/poppler.pc

# Poppler uses libopenjp2 and lcms2
# But does not declare them in poppler.pc

echo "Before patching"
cat $PC_FILE

echo "Requires.private: libopenjp2 lcms2" >> $PC_FILE

echo ""
echo "After patching"
cat $PC_FILE
