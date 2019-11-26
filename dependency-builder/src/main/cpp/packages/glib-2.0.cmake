include_guard(GLOBAL)

ExternalProjectMeson(glib-2.0
  DEPENDS iconv intl libffi zlib
  URL https://download.gnome.org/sources/glib/2.62/glib-2.62.3.tar.xz
  URL_HASH SHA256=4400adc9f0d3ffcfe8e84225210370ce3f9853afb81812ddadb685325aa655c4
  CONFIGURE_ARGUMENTS -Dlibmount=false
)

