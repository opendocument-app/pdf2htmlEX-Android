include_guard(GLOBAL)

# CMAKE issue 8905: FindTIFF should link to jpeg library
# https://gitlab.kitware.com/cmake/cmake/issues/8905
# https://cmake.org/Bug/view.php?id=8905
# @TODO: http://bugzilla.maptools.org/createaccount.cgi
#
# Current workaround is twofold:
# 1) build libTIFF using Autotools, because Autotools based build generates coorect pkg-config.pc file
# 2) Consume libTIFF using pkg-config (or it's wrapper in CMake pkg_search_module(TIFF libtiff-4))

ExternalProjectAutotools(libtiff-4
  DEPENDS libjpeg
  URL https://download.osgeo.org/libtiff/tiff-4.3.0.tar.gz
  URL_HASH SHA256=0e46e5acb087ce7d1ac53cf4f56a09b221537fc86dfc5daaad1c2e89e1b37ac8
)
