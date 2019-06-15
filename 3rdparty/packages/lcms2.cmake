include_guard(GLOBAL)

ExternalProjectAutotools(lcms2
  DEPENDS libjpeg libtiff-4
  URL https://kent.dl.sourceforge.net/project/lcms/lcms/2.9/lcms2-2.9.tar.gz
  URL_HASH SHA256=48c6fdf98396fa245ed86e622028caf49b96fa22f3e5734f853f806fbc8e7d20
  # lcms cannot find jpeg and tiff on it's own
  CONFIGURE_ARGUMENTS --with-jpeg=${THIRDPARTY_PREFIX} --with-tiff=${THIRDPARTY_PREFIX}
)
