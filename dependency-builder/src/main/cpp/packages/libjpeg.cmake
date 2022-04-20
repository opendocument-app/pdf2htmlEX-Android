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
  URL https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.1.3.tar.gz
  URL_HASH SHA256=dbda0c685942aa3ea908496592491e5ec8160d2cf1ec9d5fd5470e50768e7859
  ${LIBJPEG_SHARED_ARGUMENT}
)
