include_guard(GLOBAL)

# Freetype needs to be built with Autotools, because CMake build
# produces "freetype-config.cmake" alongside the pkg-config.pc file.
# freetype-config.cmake produces errors when included in fontconfig

ExternalProjectAutotools(freetype
  DEPENDS libpng zlib
  URL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.2.tar.xz
  URL_HASH SHA512=cf45089bd8893d7de2cdcb59d91bbb300e13dd0f0a9ef80ed697464ba7aeaf46a5a81b82b59638e6b21691754d8f300f23e1f0d11683604541d77f0f581affaa

  CONFIGURE_ARGUMENTS --with-zlib=yes --with-bzip2=no
    --with-png=yes
    --with-harfbuzz=no
)

