include_guard(GLOBAL)

ExternalProjectMeson(glib-2.0
  DEPENDS iconv intl libffi zlib

  URL https://download.gnome.org/sources/glib/2.62/glib-2.62.6.tar.xz
  URL_HASH SHA256=104fa26fbefae8024ff898330c671ec23ad075c1c0bce45c325c6d5657d58b9c

  CONFIGURE_ARGUMENTS -Dlibmount=false
)

