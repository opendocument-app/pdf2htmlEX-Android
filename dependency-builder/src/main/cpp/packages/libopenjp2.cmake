include_guard(GLOBAL)

ExternalProjectCMake(libopenjp2
  DEPENDS lcms2 libpng libtiff-4 libjpeg
  URL https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.4.0.tar.gz
  URL_HASH SHA256=8702ba68b442657f11aaeb2b338443ca8d5fb95b0d845757968a7be31ef7f16d
  CONFIGURE_ARGUMENTS -DBUILD_CODEC=OFF
)
