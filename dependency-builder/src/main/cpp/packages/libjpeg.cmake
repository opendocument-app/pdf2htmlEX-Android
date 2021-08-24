include_guard(GLOBAL)

#ExternalProjectAutotools(libjpeg
  #URL https://www.ijg.org/files/jpegsrc.v9c.tar.gz
  #URL_HASH SHA256=650250979303a649e21f87b5ccd02672af1ea6954b911342ea491f351ceb7122
#)

# libjpeg-turbo
if (NOT BUILD_SHARED_LIBS)
  SET(LIBJPEG_SHARED_ARGUMENT CONFIGURE_ARGUMENTS -DENABLE_SHARED=FALSE)
endif (NOT BUILD_SHARED_LIBS)

ExternalProjectCMake(libjpeg
  URL https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.4.tar.gz
  URL_HASH SHA256=7777c3c19762940cff42b3ba4d7cd5c52d1671b39a79532050c85efb99079064
  LICENSE_FILES LICENSE.md README.ijg
  ${LIBJPEG_SHARED_ARGUMENT}
)

