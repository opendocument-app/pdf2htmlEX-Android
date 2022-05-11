include_guard(GLOBAL)

# Freetype needs to be built with Autotools, because CMake build
# produces "freetype-config.cmake" alongside the pkg-config.pc file.
# freetype-config.cmake produces errors when included in fontconfig

ExternalProjectAutotools(freetype
  DEPENDS libpng zlib
  URL https://download.sourceforge.net/freetype/freetype-2.12.1.tar.xz
  URL_HASH SHA256=4766f20157cc4cf0cd292f80bf917f92d1c439b243ac3018debf6b9140c41a7f

  CONFIGURE_ARGUMENTS
    --with-zlib=yes
    --with-png=yes
    --with-brotli=no
    --with-bzip2=no
    --with-harfbuzz=no
)
