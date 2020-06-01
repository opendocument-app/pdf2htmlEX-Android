#!/bin/sh
set -eu

SRC_DIR=$1
THIRDPARTY_PREFIX=$2

mkdir -p $THIRDPARTY_PREFIX/share/fonts
cp -v $SRC_DIR/d050000l.pfb $THIRDPARTY_PREFIX/share/fonts/
cp -v $SRC_DIR/s050000l.pfb $THIRDPARTY_PREFIX/share/fonts/
