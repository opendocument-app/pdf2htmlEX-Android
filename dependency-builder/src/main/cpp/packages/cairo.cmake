include_guard(GLOBAL)

ExternalProjectAutotools(cairo
  DEPENDS fontconfig freetype glib-2.0 iconv libpng libxml-2.0 pixman-1
  URL https://cairographics.org/snapshots/cairo-1.17.4.tar.xz
  URL_HASH SHA256=74b24c1ed436bbe87499179a3b27c43f4143b8676d8ad237a6fa787401959705
  LICENSE_FILES COPYING COPYING-LGPL-2.1 COPYING-MPL-1.1
  CONFIGURE_ARGUMENTS --enable-xml
)

