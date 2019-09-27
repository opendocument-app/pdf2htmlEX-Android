include_guard(GLOBAL)

ExternalProjectCMake(libopenjp2
  DEPENDS lcms2 libpng libtiff-4
  URL https://github.com/uclouvain/openjpeg/archive/v2.3.1.tar.gz
  URL_HASH SHA256=63f5a4713ecafc86de51bfad89cc07bb788e9bba24ebbf0c4ca637621aadb6a9
)

