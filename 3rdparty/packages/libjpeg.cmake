include_guard(GLOBAL)

ExternalProjectAutotools(libjpeg
  URL https://www.ijg.org/files/jpegsrc.v9c.tar.gz
  URL_HASH SHA256=650250979303a649e21f87b5ccd02672af1ea6954b911342ea491f351ceb7122
)

# libjpeg-turbo
# if (NOT BUILD_SHARED_LIBS)
#   SET(LIBJPEG_SHARED_ARGUMENT CONFIGURE_ARGUMENTS -DENABLE_SHARED=FALSE)
# endif (NOT BUILD_SHARED_LIBS)
# ExternalProjectCMake(libjpeg
#   #URL https://
#   URL ${TARBALL_STORAGE}/libjpeg-turbo-2.0.2.tar.gz
#   URL_HASH SHA256=acb8599fe5399af114287ee5907aea4456f8f2c1cc96d26c28aebfdf5ee82fed
#   ${LIBJPEG_SHARED_ARGUMENT}
# )
