include_guard(GLOBAL)

ExternalProjectCMake(libopenjp2
  DEPENDS lcms2 libpng libtiff-4 libjpeg
  URL https://github.com/uclouvain/openjpeg/releases/download/v2.4.0/openjpeg-v2.4.0-linux-x86_64.tar.gz
  URL_HASH SHA256=0c3aae80679504fa3727f3f3779defc0746c08d83e49ef1f262baf5d916cd5f9
  CONFIGURE_ARGUMENTS -DBUILD_CODEC=OFF
)
