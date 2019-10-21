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
  URL https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.3.tar.gz
  URL_HASH SHA256=a69598bf079463b34d45ca7268462a18b6507fdaa62bb1dfd212f02041499b5d
  ${LIBJPEG_SHARED_ARGUMENT}
)

