include_guard(GLOBAL)

message(FATAL_ERROR "libopenjp2 disabled, space saving")

ExternalProjectCMake(libopenjp2
  DEPENDS lcms2 libpng libtiff-4
  URL https://github.com/uclouvain/openjpeg/archive/v2.3.1.tar.gz
  URL_HASH SHA256=63f5a4713ecafc86de51bfad89cc07bb788e9bba24ebbf0c4ca637621aadb6a9
  EXTRA_ARGUMENTS
    # Force linking against libjpeg when linking against libtiff
    UPDATE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixLibopenjp2Source.sh ${CMAKE_CURRENT_BINARY_DIR}/libopenjp2-prefix/src/libopenjp2/
    LOG_UPDATE 1
)
