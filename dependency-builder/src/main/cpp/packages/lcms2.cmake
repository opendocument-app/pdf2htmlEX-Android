include_guard(GLOBAL)

ExternalProjectAutotools(lcms2
  DEPENDS libjpeg libtiff-4
  URL https://github.com/mm2/Little-CMS/releases/download/lcms2.13.1/lcms2-2.13.1.tar.gz
  URL_HASH SHA256=d473e796e7b27c5af01bd6d1552d42b45b43457e7182ce9903f38bb748203b88
  # lcms cannot find jpeg and tiff on it's own
  CONFIGURE_ARGUMENTS --with-jpeg=${THIRDPARTY_PREFIX} --with-tiff=${THIRDPARTY_PREFIX}
)
