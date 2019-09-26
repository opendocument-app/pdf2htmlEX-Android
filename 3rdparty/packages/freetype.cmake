include_guard(GLOBAL)

ExternalProjectAutotools(freetype
  DEPENDS libpng zlib
  URL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.xz
  URL_HASH SHA256=16dbfa488a21fe827dc27eaf708f42f7aa3bb997d745d31a19781628c36ba26f

  CONFIGURE_ARGUMENTS --with-zlib=yes --with-bzip2=no
    --with-png=yes
    --with-harfbuzz=no
)

