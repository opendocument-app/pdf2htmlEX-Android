include_guard(GLOBAL)

ExternalProjectMeson(pango
  DEPENDS cairo fontconfig freetype fribidi glib-2.0 harfbuzz

  # Issue #65
#  https://download.gnome.org/sources/pango/1.50/pango-1.50.7.tar.xz
#  0477f369a3d4c695df7299a6989dc004756a7f4de27eecac405c6790b7e3ad33

#  https://download.gnome.org/sources/pango/1.50/pango-1.50.0.tar.xz
#  dba8b62ddf86e10f73f93c3d2256b73238b2bcaf87037ca229b40bdc040eb3f3

  URL https://download.gnome.org/sources/pango/1.49/pango-1.49.4.tar.xz
  URL_HASH SHA256=1fda6c03161bd1eacfdc349244d26828c586d25bfc600b9cfe2494902fdf56cf
  CONFIGURE_ARGUMENTS -Dintrospection=disabled
)
