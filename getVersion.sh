#!/bin/sh
set -eu

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

# Extract project version from build.gradle
gradle_file=$BASEDIR/pdf2htmlEX/build.gradle
version_format='([0-9\.]+)'
expression="s/^version \= ['\"]$version_format['\"]\$/\1/p"
sed -En "--expression=$expression" $gradle_file

