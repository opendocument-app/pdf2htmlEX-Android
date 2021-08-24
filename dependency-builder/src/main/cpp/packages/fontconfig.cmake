include_guard(GLOBAL)

ExternalProjectMeson(fontconfig
  DEPENDS freetype libexpat
  URL https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.93.tar.xz
  URL_HASH SHA256=ea968631eadc5739bc7c8856cef5c77da812d1f67b763f5e51b57b8026c1a0a0
  LICENSE_FILES COPYING

  CONFIGURE_ARGUMENTS
    -Dnls=enabled
    -Ddoc=disabled
    -Dtests=disabled
    -Dtools=disabled
)

