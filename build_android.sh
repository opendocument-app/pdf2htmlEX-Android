#!/bin/sh
set -euo pipefail
shopt -s failglob

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

APP=$BASEDIR/android
LIB=$BASEDIR/lib-android
THIRD_PARTY_DIR=$BASEDIR/3rdparty
THIRD_PARTY_DIR_SLASH_ESCAPED="${THIRD_PARTY_DIR//\//\\\/}\/"

# Generate library gradle project based on Android app
if ! test -d "$LIB"
then
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

# Build 3rdparty libraries
cd $LIB
./gradlew assemble

function wait_on_children_processes() {
  for pid in $pids
  do
    if ! wait $pid
    then
      echo "Build failed. Waiting for other subprocesses..."
      wait
      exit 1
    fi
  done
}

pids=
for build_target in $THIRD_PARTY_DIR/built/cmake/*/*
do
  cmake --build $build_target &
  pids="$pids $!"
done
wait_on_children_processes $pids

# Build pdf2htmlEX
cd $APP
./gradlew assemble

pids=
for build_target in $APP/app/.externalNativeBuild/cmake/*/*
do
  (
    set -euo pipefail
    cmake --build $build_target --target install

    abi=$(basename $build_target)
    build_type=$(basename ${build_target%$abi})

    # UPX only works on armeabi-v7a
    # Other ABIs produce segfaults.
    if test $abi = "armeabi-v7a"
    then
      upx --ultra-brute --8mib-ram $build_target/built/bin/pdf2htmlEX
    fi

    # Compress binaries and other files into .tar's
    mkdir --parents $build_target/built/sample_pdfs
    cp $BASEDIR/test/browser_tests/*.pdf $build_target/built/sample_pdfs/

    tar --create --file $build_target/$build_type-$abi-pdf2htmlEX.tar --directory $build_target built
  ) &
  pids="$pids $!"
done
wait_on_children_processes $pids

for ft in $APP/app/.externalNativeBuild/cmake/*/*/*-pdf2htmlEX.tar
do
  echo "$ft is ready!"
done

