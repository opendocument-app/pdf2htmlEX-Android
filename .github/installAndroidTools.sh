#!/bin/sh
set -eu

if test ! -d $ANDROID_HOME/tools/bin/sdkmanager
then
  wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_TOOLS.zip
  sudo unzip -d $ANDROID_HOME android-sdk.zip > /dev/null
  rm android-sdk.zip
fi

echo "y" | sudo $ANDROID_HOME/tools/bin/sdkmanager "tools" > /dev/null
echo "y" | sudo $ANDROID_HOME/tools/bin/sdkmanager --licenses > /dev/null

echo "y" | sudo $ANDROID_HOME/tools/bin/sdkmanager "cmake;$ANDROID_CMAKE" > /dev/null
echo "y" | sudo $ANDROID_HOME/tools/bin/sdkmanager "ndk;$ANDROID_NDK" > /dev/null

