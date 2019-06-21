include_guard(GLOBAL)

# armeabi-v7a fails to build libffi. However, glib-2.0 manages to build it internally.
SET(LIBFFI_DEPENDENCY libffi)
if(ANDROID_ABI STREQUAL armeabi-v7a)
  SET(LIBFFI_DEPENDENCY)
endif()

ExternalProjectMeson(glib-2.0
  DEPENDS iconv gettext ${LIBFFI_DEPENDENCY}
  URL https://ftp.gnome.org/pub/gnome/sources/glib/2.61/glib-2.61.1.tar.xz
  URL_HASH SHA256=f8d827955f0d8e197ff5c2105dd6ac4f6b63d15cd021eb1de66534c92a762161
  CONFIGURE_ARGUMENTS -Dlibmount=false

  EXTRA_ARGUMENTS
  UPDATE_COMMAND
    #@TODO: attempt to libiconv.pc (pkg-config) so that this hack would not be needed
    ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixGlibSource.sh
    ${CMAKE_CURRENT_BINARY_DIR}/glib-2.0-prefix/src/glib-2.0/
    ${THIRDPARTY_PREFIX}

  # glib uses libintl (from gettext), but the glib-2.0.pc is wrong
  # libintl.a needs to be included after libglib-2.0
  TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixGlibInstall.sh ${THIRDPARTY_PREFIX}
  LOG_TEST 1
)
