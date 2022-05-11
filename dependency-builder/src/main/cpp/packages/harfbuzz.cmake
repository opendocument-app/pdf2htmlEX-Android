include_guard(GLOBAL)

ExternalProjectMeson(harfbuzz
  DEPENDS cairo fontconfig freetype glib-2.0
  URL https://github.com/harfbuzz/harfbuzz/releases/download/4.2.1/harfbuzz-4.2.1.tar.xz
  URL_HASH SHA256=bd17916513829aeff961359a5ccebba6de2f4bf37a91faee3ac29c120e3d7ee1

  # Meson tests don't really work when cross compiling
  CONFIGURE_ARGUMENTS -Dtests=disabled
)
