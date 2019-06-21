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

# Fix sent upstream:
# https://github.com/fontforge/fontforge/pull/3746
#
# android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/langinfo.h:char*
# if __ANDROID_API__ >= 26
# char* nl_langinfo(nl_item __item) __INTRODUCED_IN(26);
# char* nl_langinfo_l(nl_item __item, locale_t __l) __INTRODUCED_IN(26);
# #endif /* __ANDROID_API__ >= 26 */

patch $1/fontforge/noprefs.c < ${BASEDIR}/libfontforgeNoprefs.patch
