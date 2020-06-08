#!/bin/sh
set -eu

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

# Input vars
# 1: Package Name
# 2: Source (to be patched) directory
# 3: Installed (prefix) directory
#
# Environment:
# ANDROID = 1
# ANDROID_NATIVE_API_LEVEL=21

PACKAGE_NAME=$1
SOURCE_DIR=$2
PREFIX_DIR=$3

if test -f $SOURCE_DIR/source-already-patched; then
  exit 0
fi

if test -f $BASEDIR/packages/${PACKAGE_NAME}-Patch-Source.sh; then
  $BASEDIR/packages/${PACKAGE_NAME}-Patch-Source.sh ${SOURCE_DIR} ${PREFIX_DIR}
else
  patches=$(find $BASEDIR/packages -name "${PACKAGE_NAME}-Patch-Source*.patch" -printf "%f\n" | sort)
  for p in $patches; do
    echo "Applying patch ${p}"
    patch -p0 < $BASEDIR/packages/$p
    echo ""
  done
fi

echo "Source patched" > $SOURCE_DIR/source-already-patched
