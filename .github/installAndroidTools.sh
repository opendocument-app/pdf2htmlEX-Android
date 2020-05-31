#!/bin/sh
set -eu

if test ! -f $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager
then
  cmdtoolsfile=commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
  if test ! -f ${cmdtoolsfile}
  then
    wget --quiet "https://dl.google.com/android/repository/${cmdtoolsfile}" --output-document "${cmdtoolsfile}"
  fi
  sudo unzip -d $ANDROID_HOME/cmdline-tools ${cmdtoolsfile} > /dev/null
fi

echo "y" | sudo $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "tools" > /dev/null
echo "y" | sudo $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager --licenses > /dev/null

echo "y" | sudo $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "cmake;$ANDROID_CMAKE" > /dev/null
echo "y" | sudo $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "ndk;$ANDROID_NDK" > /dev/null
