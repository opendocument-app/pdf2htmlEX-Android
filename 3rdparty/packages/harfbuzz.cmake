include_guard(GLOBAL)

ExternalProjectAutotools(harfbuzz
  DEPENDS cairo glib-2.0 freetype
  URL https://github.com/harfbuzz/harfbuzz/releases/download/2.6.1/harfbuzz-2.6.1.tar.xz
  URL_HASH SHA256=c651fb3faaa338aeb280726837c2384064cdc17ef40539228d88a1260960844f
  CONFIGURE_ARGUMENTS 
    --with-glib=yes
    --with-cairo=yes
    --with-freetype=yes
    --with-icu=no
    --with-fontconfig=no
)

