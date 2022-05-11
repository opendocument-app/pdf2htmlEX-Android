include_guard(GLOBAL)

ExternalProjectAutotools(libxml-2.0
  DEPENDS iconv
  URL https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz
  URL_HASH SHA256=60d74a257d1ccec0475e749cba2f21559e48139efba6ff28224357c7c798dfee
  CONFIGURE_ARGUMENTS --without-python
)
