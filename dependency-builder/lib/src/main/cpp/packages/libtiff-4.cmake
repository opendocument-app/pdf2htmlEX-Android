include_guard(GLOBAL)

# CMAKE issue 8905: FindTIFF should link to jpeg library
# https://gitlab.kitware.com/cmake/cmake/issues/8905
# https://cmake.org/Bug/view.php?id=8905
# @TODO: http://bugzilla.maptools.org/createaccount.cgi
# Current workaround is two fold:

# Manually link against libjpeg in all packages, which depend on libtiff.
# These packages are: libopenjp2 and poppler

ExternalProjectCMake(libtiff-4
  DEPENDS libjpeg
  URL http://download.osgeo.org/libtiff/tiff-4.0.10.tar.gz
  URL_HASH SHA256=2c52d11ccaf767457db0c46795d9c7d1a8d8f76f68b0b800a3dfe45786b996e4
)

