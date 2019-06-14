include_guard(GLOBAL)

ExternalProjectMeson(glib-2.0
  DEPENDS libffi iconv
  URL https://ftp.gnome.org/pub/gnome/sources/glib/2.61/glib-2.61.1.tar.xz
  #URL ${TARBALL_STORAGE}/glib-2.61.1.tar.xz
  URL_HASH SHA256=f8d827955f0d8e197ff5c2105dd6ac4f6b63d15cd021eb1de66534c92a762161
  CONFIGURE_ARGUMENTS -Dlibmount=false
)
