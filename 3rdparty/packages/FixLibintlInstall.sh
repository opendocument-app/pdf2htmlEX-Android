#!/bin/bash
set -euo pipefail

THIRDPARTY_PREFIX=$1

rm -v ${THIRDPARTY_PREFIX}/lib/libintl.so
