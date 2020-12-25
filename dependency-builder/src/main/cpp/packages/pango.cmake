include_guard(GLOBAL)

ExternalProjectMeson(pango
  DEPENDS cairo fontconfig freetype fribidi glib-2.0 harfbuzz
  URL https://download.gnome.org/sources/pango/1.48/pango-1.48.0.tar.xz
  URL_HASH SHA256=391f26f3341c2d7053e0fb26a956bd42360dadd825efe7088b1e9340a65e74e6
  CONFIGURE_ARGUMENTS -Dintrospection=disabled
)

