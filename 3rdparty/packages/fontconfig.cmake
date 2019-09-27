include_guard(GLOBAL)

ExternalProjectAutotools(fontconfig
  DEPENDS freetype iconv libxml-2.0
  URL https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.92.tar.xz
  URL_HASH SHA256=506e61283878c1726550bc94f2af26168f1e9f2106eac77eaaf0b2cdfad66e4e

  CONFIGURE_ARGUMENTS
    --disable-docs
    --enable-libxml2
)

