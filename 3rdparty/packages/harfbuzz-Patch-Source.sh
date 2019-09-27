#!/bin/sh
set -euo pipefail

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

patch $1/CMakeLists.txt $BASEDIR/harfbuzz-Patch-Source-glib.patch

patch $1/CMakeLists.txt $BASEDIR/harfbuzz-Patch-Source-utils-cairo.patch

