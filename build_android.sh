#!/usr/bin/env bash
set -euo pipefail

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

APP=$BASEDIR/android
LIB=$BASEDIR/lib-android
THIRD_PARTY_DIR=$BASEDIR/3rdparty
THIRD_PARTY_DIR_SLASH_ESCAPED="${THIRD_PARTY_DIR//\//\\\/}\/"

# Based on Android app generate a project for library
if [ ! -d "$LIB" ]; then
  echo "Preparing $LIB"

  # Copy necessary files from android app to android lib
  mkdir --parents --verbose $LIB/lib/src/main

  ln --symbolic --verbose $APP/gradle $LIB/gradle
  ln --symbolic --verbose $APP/build.gradle $LIB/build.gradle
  ln --symbolic --verbose $APP/gradle.properties $LIB/gradle.properties
  ln --symbolic --verbose $APP/gradlew $LIB/gradlew

  echo "include ':lib'" >> $LIB/settings.gradle

  cp --verbose $APP/app/build.gradle $LIB/lib/build.gradle

  # Change application id
  sed -i -E 's/applicationId "(.+)"/applicationId "\1.lib"/g' $LIB/lib/build.gradle

  # Change CMakeLists from pdf2htmlEX/CMakeLists.txt to 3rdparty/CMakeLists.txt
  sed -i "s/path \"..\/..\/CMakeLists.txt\"/path \"${THIRD_PARTY_DIR_SLASH_ESCAPED}CMakeLists.txt\"/g" $LIB/lib/build.gradle

  # Append buildStatingDirectory
  sed -i "/path \"${THIRD_PARTY_DIR_SLASH_ESCAPED}CMakeLists.txt\"/a buildStagingDirectory \"${THIRD_PARTY_DIR_SLASH_ESCAPED}built\"" $LIB/lib/build.gradle

  # Clear out dependecies
  sed -i -e '/dependencies/,/}/d' $LIB/lib/build.gradle
  echo 'dependencies { }' >> $LIB/lib/build.gradle

  # Generate Manifest
  echo '<?xml version="1.0" encoding="utf-8"?>' > $LIB/lib/src/main/AndroidManifest.xml
  echo '<manifest xmlns:android="http://schemas.android.com/apk/res/android"' >> $LIB/lib/src/main/AndroidManifest.xml

  # Extract package name
  grep 'package="' $APP/app/src/main/AndroidManifest.xml |
    sed -E 's/package="(.+)"/package="\1.lib"/' >> $LIB/lib/src/main/AndroidManifest.xml

  echo '</manifest>' >> $LIB/lib/src/main/AndroidManifest.xml
fi

cd $LIB
./gradlew assemble
for build_type in $THIRD_PARTY_DIR/built/cmake/*; do
  for build_type_and_abi in $build_type/*; do
  echo "Building LIB: $build_type_and_abi"
  cmake --build $build_type_and_abi
done

cd $APP
./gradlew assemble
for build_type in $APP/app/.externalNativeBuild/cmake/*; do
  for build_type_and_abi in $build_type/*; do
    cmake --build $build_type_and_abi --target install

    mkdir $build_type_and_abi/built/sample_pdfs
    cp -v $BASEDIR/test/browser_tests/*.pdf $build_type_and_abi/built/sample_pdfs/
    tar -cf $build_type_and_abi/pdf2htmlEX.tar --directory $build_type_and_abi built
    tar --list -f $build_type_and_abi/pdf2htmlEX.tar
    echo "$build_type_and_abi/pdf2htmlEX.tar is ready!"
    done
done
