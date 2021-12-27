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
  URL http://download.osgeo.org/libtiff/tiff-4.1.0.tar.gz
  URL_HASH SHA512=fd541dcb11e3d5afaa1ec2f073c9497099727a52f626b338ef87dc93ca2e23ca5f47634015a4beac616d4e8f05acf7b7cd5797fb218758cc2ad31b390491c5a6
)
