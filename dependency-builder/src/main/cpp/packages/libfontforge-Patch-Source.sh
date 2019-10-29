#!/bin/sh
set -eu

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

# fontforge uses newlocale and localeconv, which are not available on Android pre 21 (Lollipop)
# locale_t is available, we should not redefine it while using the BAD_LOCALE_HACK in splinefont.h

# From /usr/include/locale.h:
# #if __ANDROID_API__ >= 21
# locale_t duplocale(locale_t __l) __INTRODUCED_IN(21);
# void freelocale(locale_t __l) __INTRODUCED_IN(21);
# locale_t newlocale(int __category_mask, const char* __locale_name, locale_t __base) __INTRODUCED_IN(21);
# #endif /* __ANDROID_API__ >= 21 */
# ...
# #if __ANDROID_API__ >= 21
# struct lconv* localeconv(void) __INTRODUCED_IN(21);
# #endif /* __ANDROID_API__ >= 21 */
#
# #define LC_GLOBAL_LOCALE __BIONIC_CAST(reinterpret_cast, locale_t, -1L)
patch -p0 < $BASEDIR/libfontforge-Patch-Source-localeconv.patch

