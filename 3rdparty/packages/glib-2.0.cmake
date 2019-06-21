include_guard(GLOBAL)

ExternalProjectMeson(glib-2.0
  DEPENDS iconv libintl zlib libffi
  URL https://ftp.gnome.org/pub/gnome/sources/glib/2.61/glib-2.61.1.tar.xz
  URL_HASH SHA256=f8d827955f0d8e197ff5c2105dd6ac4f6b63d15cd021eb1de66534c92a762161
  CONFIGURE_ARGUMENTS -Dlibmount=false

  EXTRA_ARGUMENTS
  UPDATE_COMMAND
    ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixGlibSource.sh
    ${CMAKE_CURRENT_BINARY_DIR}/glib-2.0-prefix/src/glib-2.0/
    ${THIRDPARTY_PREFIX}
    ${ANDROID_NATIVE_API_LEVEL}
)
