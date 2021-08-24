include_guard(GLOBAL)

ExternalProjectMeson(harfbuzz
  DEPENDS cairo fontconfig freetype glib-2.0
  URL https://github.com/harfbuzz/harfbuzz/releases/download/2.6.6/harfbuzz-2.6.6.tar.xz
  URL_HASH SHA256=84d0f1fb4cf4b3ee398ac20eaa608ca9f7cd90d992a44540fdcb16469bb460e5
  LICENSE_FILES COPYING

  # Meson tests don't really work when cross compiling
  CONFIGURE_ARGUMENTS -Dtests=disabled
)

