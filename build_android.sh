#!/bin/sh
set -euo pipefail
shopt -s failglob

# 'Debug', 'Release' or empty string for both
BUILD_TYPE=

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

ANDROID_3RDPARTY_DIR=$BASEDIR/android-3rdparty
ANDROID_LIB_DIR=$BASEDIR/android-libpdf2htmlex
ANDROID_APP_DIR=$BASEDIR/android-sample-app

# This is the .externalNativeBuild
BUILD_3RDPARTY_DIR=$BASEDIR/build/3rdparty
BUILD_LIB_DIR=$BASEDIR/build/libpdf2htmlex
BUILD_APP_DIR=$BASEDIR/build/sample-app

# This is android/app/build
GRADLE_BUILD_3RDPARTY_DIR=$BASEDIR/build/gradle_3rdparty
GRADLE_BUILD_LIB_DIR=$BASEDIR/build/gradle_libpdf2htmlex
GRADLE_BUILD_APP_DIR=$BASEDIR/build/gradle_sample-app

# Use android-libpdf2htmlex as a template for android-3rdparty Android Gradle project
if ! test -d $ANDROID_3RDPARTY_DIR
then
  mkdir $ANDROID_3RDPARTY_DIR --verbose
  cp --recursive $ANDROID_LIB_DIR/app $ANDROID_3RDPARTY_DIR/app

  # Prepare build.gradle
  sed -i "s/path \"..\/..\/CMakeLists.txt\"/path \"..\/..\/3rdparty\/CMakeLists.txt\"/g" $ANDROID_3RDPARTY_DIR/app/build.gradle

  sed -i "s/buildStagingDirectory \"..\/..\/build\/libpdf2htmlex\/\"/buildStagingDirectory \"${BUILD_3RDPARTY_DIR//\//\\\/}\/\"/g" $ANDROID_3RDPARTY_DIR/app/build.gradle

  # gradle.properties defines buildDir
  grep -v 'buildDir=' $ANDROID_LIB_DIR/gradle.properties > $ANDROID_3RDPARTY_DIR/gradle.properties
  echo "buildDir=$GRADLE_BUILD_3RDPARTY_DIR" >> $ANDROID_3RDPARTY_DIR/gradle.properties
fi

to_symlink="gradle build.gradle gradlew settings.gradle"
for f in $to_symlink
do
  if ! test -e $ANDROID_3RDPARTY_DIR/$f
  then
    ln --symbolic $ANDROID_LIB_DIR/$f $ANDROID_3RDPARTY_DIR/$f --verbose
  fi
done

# Build 3rdparty libraries
cd $ANDROID_3RDPARTY_DIR
./gradlew assemble$BUILD_TYPE

pids=
for build_target in $BUILD_3RDPARTY_DIR/cmake/*/*
do
  cmake --build $build_target &
  pids="$pids $!"
done

for pid in $pids
do
  if ! wait $pid
  then
    echo "Build failed. Waiting for other subprocesses..."
    wait
    exit 1
  fi
done

# Build libpdf2htmlEX
cd $ANDROID_LIB_DIR
./gradlew assemble$BUILD_TYPE

for build_target in $BUILD_LIB_DIR/cmake/*/*
do
  cmake --build $build_target --target install

  abi=$(basename $build_target)
  build_type=$(basename ${build_target%$abi})

  # ######
  # UPX disabled because it fails for shared libraries...
  # ######
  # UPX only works on armeabi-v7a
  # Other ABIs produce segfaults.
  # Also no point in compressing debug builds.
  #if test $abi = "armeabi-v7a" && test "$build_type" != "debug"
  #then
  #  upx --ultra-brute --8mib-ram $build_target/built/lib/libpdf2htmlEX.so
  #fi
done

# Rename .cmake.in to .cmake and pack it into .tar
tar --create --file $BASEDIR/build/pdf2htmlEX-release.tar --directory=$BASEDIR pdf2htmlEX.cmake.in --transform 's,^pdf2htmlEX.cmake.in$,jniLibs/pdf2htmlEX.cmake,'
tar --create --file $BASEDIR/build/pdf2htmlEX-debug.tar --directory=$BASEDIR pdf2htmlEX.cmake.in --transform 's,^pdf2htmlEX.cmake.in$,jniLibs/pdf2htmlEX.cmake,'

function add_to_tar() {
  folder=$1
  prefix_in_tar=$2
  include_abi=$3

  for build_type_ in $BUILD_LIB_DIR/cmake/*
  do
    build_type=$(basename $build_type_)
    tar_file=$BASEDIR/build/pdf2htmlEX-$build_type.tar

    for build_target in $build_type_/*
    do
      abi=$(basename $build_target)

      if $include_abi
      then
        prefix_in_tar=$2/$abi
      fi

      for f in $build_target/built/$folder/*
      do
        fname=$(basename $f)

        # Check if this file is the same as those provided by other ABIs
        if ! $include_abi && ! diff --brief --from-file $BUILD_LIB_DIR/cmake/$build_type/*/built/$folder/$fname
        then
          echo "ERROR: Included file $f is not the same in all ABIs!"
          ls -lha $BUILD_LIB_DIR/cmake/$build_type/*/built/$folder/$fname
          exit 1
        fi

        tar --append --file $tar_file --directory=$build_target/built/$folder $fname --transform "s,^,$prefix_in_tar/,"
      done

      if ! $include_abi
      then
        # Do not process other ABIs, everything already included from this one
        break
      fi
    done
  done
}

add_to_tar "lib" "jniLibs" true
add_to_tar "include" "jniLibs/include" false
add_to_tar "share/pdf2htmlEX" "assets/pdf2htmlEX" false

# Load libpdf2htmlEX into sample android app
tar_to_load=$BASEDIR/build/pdf2htmlEX-release.tar
if test "$BUILD_TYPE" = "Debug"
then
  tar_to_load=$BASEDIR/build/pdf2htmlEX-debug.tar
fi

tar --extract --file $tar_to_load --directory=$ANDROID_APP_DIR/app/src/main jniLibs assets

# Build sample android app
cd $ANDROID_APP_DIR
./gradlew assemble$BUILD_TYPE

