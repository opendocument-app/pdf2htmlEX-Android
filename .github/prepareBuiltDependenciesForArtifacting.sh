#!/bin/sh
set -eu

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")/..

for abi in $BASEDIR/dependency-builder/.cxx/cmake/release/*/installed
do
  find $abi -mindepth 1 -maxdepth 1 -not \( -name 'bin' -o -name 'include' -o -name 'lib' -o -name 'share' \) -exec rm -r {} \;

  find $abi/bin -type f -not -name 'pkg-config' -exec rm {} \;

  find $abi/share -mindepth 1 -maxdepth 1 -type d -not \( -name 'pdf2htmlEX' -o -name 'poppler' -o -name 'pkgconfig' \) -exec rm -r {} \;
done

