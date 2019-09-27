#!/bin/sh
set -euo pipefail

THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")

#android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/pwd.h
#if __ANDROID_API__ >= 26
#struct passwd* getpwent(void) __INTRODUCED_IN(26);
#void setpwent(void) __INTRODUCED_IN(26);
#void endpwent(void) __INTRODUCED_IN(26);
#endif /* __ANDROID_API__ >= 26 */
patch $1/gutils/fsys.c $BASEDIR/libfontforge-Patch-Source-fsys.patch

# https://android.googlesource.com/platform/bionic/+/master/docs/status.md
#New libc functions in P (API level 28):
#endhostent/endnetent/endprotoent/getnetent/getprotoent/sethostent/setnetent/setprotoent (completing <netdb.h>)
patch $1/gutils/gutils.c $BASEDIR/libfontforge-Patch-Source-gutils.patch

# Leak some memory by not calling endhostent() and endprotoent()
# These are deprecated functions, not used in the current upstream version of fontforge
patch $1/fontforge/http.c $BASEDIR/libfontforge-Patch-Source-http.patch

# Fix sent upstream:
# https://github.com/fontforge/fontforge/pull/3746
# Available in fontforge-20190801
#
# android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/langinfo.h:char*
# if __ANDROID_API__ >= 26
# char* nl_langinfo(nl_item __item) __INTRODUCED_IN(26);
# char* nl_langinfo_l(nl_item __item, locale_t __l) __INTRODUCED_IN(26);
# #endif /* __ANDROID_API__ >= 26 */
patch $1/fontforge/noprefs.c $BASEDIR/libfontforge-Patch-Source-noprefs.patch

