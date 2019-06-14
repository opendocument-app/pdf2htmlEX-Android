include_guard(GLOBAL)

ExternalProjectCMake(libopenjp2
  DEPENDS libpng libtiff-4 lcms2
  URL https://github.com/uclouvain/openjpeg/archive/v2.3.1.tar.gz
  #URL ${TARBALL_STORAGE}/openjpeg-2.3.1.tar.gz
  URL_HASH SHA256=63f5a4713ecafc86de51bfad89cc07bb788e9bba24ebbf0c4ca637621aadb6a9
  EXTRA_ARGUMENTS
    UPDATE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixLibopenjp2Source.sh ${CMAKE_CURRENT_BINARY_DIR}/libopenjp2-prefix/src/libopenjp2/
    LOG_UPDATE 1
)
