include_guard(GLOBAL)

#@TODO: Patch pixman-1 to build static library

ExternalProjectMeson(pixman-1
  DEPENDS libpng glib-2.0
  URL https://cairographics.org/releases/pixman-0.38.4.tar.gz
  #URL ${TARBALL_STORAGE}/pixman-0.38.4.tar.gz
  URL_HASH SHA256=da66d6fd6e40aee70f7bd02e4f8f76fc3f006ec879d346bae6a723025cfbdde7
)
