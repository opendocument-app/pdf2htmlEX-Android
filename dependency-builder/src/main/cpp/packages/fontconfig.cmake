include_guard(GLOBAL)

ExternalProjectMeson(fontconfig
  DEPENDS freetype libexpat
  URL https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.96.tar.xz
  URL_HASH SHA256=d816a920384aa91bc0ebf20c3b51c59c2153fdf65de0b5564bf9e8473443d637

  CONFIGURE_ARGUMENTS
    -Dnls=enabled
    -Ddoc=disabled
    -Dtests=disabled
    -Dtools=disabled
)
