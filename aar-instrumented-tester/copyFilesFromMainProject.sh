#!/bin/sh
set -eu

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

function symlinkFromMain() {
  if test ! -e "$BASEDIR/$1"
  then
    ln -s $BASEDIR/../$1 $BASEDIR/$1
  fi
}

symlinkFromMain gradle
symlinkFromMain pdf2htmlEX/src/androidTest/assets
symlinkFromMain build.gradle
symlinkFromMain gradle.properties
symlinkFromMain gradlew

function copyTestFile() {
  SRC=$BASEDIR/../pdf2htmlEX/src/androidTest/java/com/viliussutkus89/android/pdf2htmlex/${1}.java
  DST=$BASEDIR/pdf2htmlEX/src/androidTest/java/com/viliussutkus89/android/tester/${1}AAR.java
  
  cp $SRC $DST

  SRC_PKGNAME="com.viliussutkus89.android.pdf2htmlex"
  sed -i "s/package $SRC_PKGNAME\;/package com.viliussutkus89.android.tester;\nimport $SRC_PKGNAME.pdf2htmlEX\;/g" $DST
  sed -i "s/public class $1/public class ${1}AAR/g" $DST
}

copyTestFile InstrumentedTests

# Fontconfig tests unavailable through aar, because required jni call is unavail
#copee FontconfigInstrumentedTests

