#!/usr/bin/env bash
set -euo pipefail

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

# android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/pwd.h
#if __ANDROID_API__ >= 26
#struct passwd* getpwent(void) __INTRODUCED_IN(26);
#void setpwent(void) __INTRODUCED_IN(26);
#void endpwent(void) __INTRODUCED_IN(26);
#endif /* __ANDROID_API__ >= 26 */
patch $1/gutils/fsys.c < ${BASEDIR}/libfontforgeFsys.patch

