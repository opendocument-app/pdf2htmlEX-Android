#!/bin/sh
set -eu

if test ! -d $ANDROID_HOME/tools/bin/sdkmanager
then
  if test ! -f android-sdk/android-sdk.zip
  then
    mkdir --parents android-sdk
    wget --quiet --output-document=android-sdk/android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_TOOLS.zip
  fi
  sudo unzip -d $ANDROID_HOME android-sdk/android-sdk.zip > /dev/null
fi

echo "y" | sudo $ANDROID_HOME/tools/bin/sdkmanager "tools" > /dev/null
echo "y" | sudo $ANDROID_HOME/tools/bin/sdkmanager --licenses > /dev/null

echo "y" | sudo $ANDROID_HOME/tools/bin/sdkmanager "cmake;$ANDROID_CMAKE" > /dev/null
echo "y" | sudo $ANDROID_HOME/tools/bin/sdkmanager "ndk;$ANDROID_NDK" > /dev/null

