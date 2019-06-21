#!/bin/bash
set -euo pipefail

THIRDPARTY_PREFIX=$1
PC_TARGET_DIR=${THIRDPARTY_PREFIX}/lib/pkgconfig/

if [ ! -d "${PC_TARGET_DIR}" ]; then
  mkdir -p -v "${PC_TARGET_DIR}"
fi

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")
echo "prefix=\"${THIRDPARTY_PREFIX}\"" > $PC_TARGET_DIR/iconv.pc
cat ${BASEDIR}/iconv.pc.in >> $PC_TARGET_DIR/iconv.pc
