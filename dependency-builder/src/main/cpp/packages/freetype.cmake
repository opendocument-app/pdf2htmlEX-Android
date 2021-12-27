include_guard(GLOBAL)

# Freetype needs to be built with Autotools, because CMake build
# produces "freetype-config.cmake" alongside the pkg-config.pc file.
# freetype-config.cmake produces errors when included in fontconfig

ExternalProjectAutotools(freetype
  DEPENDS libpng zlib
  URL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.4.tar.xz
  URL_HASH SHA512=827cda734aa6b537a8bcb247549b72bc1e082a5b32ab8d3cccb7cc26d5f6ee087c19ce34544fa388a1eb4ecaf97600dbabc3e10e950f2ba692617fee7081518f

  CONFIGURE_ARGUMENTS
    --with-zlib=yes
    --with-png=yes
    --with-brotli=no
    --with-bzip2=no
    --with-harfbuzz=no
)
