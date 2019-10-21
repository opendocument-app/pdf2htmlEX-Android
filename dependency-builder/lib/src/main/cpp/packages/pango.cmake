include_guard(GLOBAL)

ExternalProjectMeson(pango
  DEPENDS cairo fontconfig freetype fribidi glib-2.0 harfbuzz
  URL https://ftp.gnome.org/pub/GNOME/sources/pango/1.44/pango-1.44.6.tar.xz
  URL_HASH SHA256=3e1e41ba838737e200611ff001e3b304c2ca4cdbba63d200a20db0b0ddc0f86c
  CONFIGURE_ARGUMENTS -Dintrospection=false
)

