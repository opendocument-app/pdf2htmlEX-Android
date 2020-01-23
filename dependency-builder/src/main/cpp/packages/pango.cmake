include_guard(GLOBAL)

ExternalProjectMeson(pango
  DEPENDS cairo fontconfig freetype fribidi glib-2.0 harfbuzz
#  URL https://ftp.gnome.org/pub/GNOME/sources/pango/1.44/pango-1.44.7.tar.xz
  URL ftp://ftp.gnome.org/pub/GNOME/sources/pango/1.44/pango-1.44.7.tar.xz
  URL_HASH SHA256=66a5b6cc13db73efed67b8e933584509f8ddb7b10a8a40c3850ca4a985ea1b1f
  CONFIGURE_ARGUMENTS -Dintrospection=false
)

