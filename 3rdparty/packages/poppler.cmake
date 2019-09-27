include_guard(GLOBAL)

# Poppler current is 0.77.0
# Poppler 0.73.0 removed goo/gtypes.h, which is used by us, can't upgrade until we react to change
# https://gitlab.freedesktop.org/poppler/poppler/commit/ef3ef702bc3dc845731e43215400448c5324efd4

# 0.71.0 removed GBool and others.
# Replace GBool, gTrue, and gFalse by bool, true, false, resp. 
# https://gitlab.freedesktop.org/poppler/poppler/commit/163420b48bdddf9084208b3cadf04dafad52d40a

# Poppler 0.64 dropped fontconfig requirement for android.
# fontconfig was never available for android.

# Usable versions >= 0.64.0 AND <= 0.70.1

IF (BUILD_3RDPARTY_BINARIES)
  SET(POPPLER_CONFIGURE_ARGUMENTS -DBUILD_CPP_TESTS=ON -DENABLE_UTILS=ON)
ELSE()
  SET(POPPLER_CONFIGURE_ARGUMENTS -DBUILD_CPP_TESTS=OFF -DENABLE_UTILS=OFF)
ENDIF ()

ExternalProjectCMake(poppler
  DEPENDS cairo freetype glib-2.0 lcms2 libpng libjpeg libopenjp2 libtiff-4 poppler-data

  URL https://poppler.freedesktop.org/poppler-0.68.0.tar.xz
  URL_HASH SHA256=f90d04f0fb8df6923ecb0f106ae866cf9f8761bb537ddac64dfb5322763d0e58

  CONFIGURE_ARGUMENTS -DENABLE_XPDF_HEADERS=ON
    -DBUILD_GTK_TESTS=OFF -DBUILD_QT5_TESTS=OFF -DENABLE_QT5=OFF
    -DENABLE_LIBOPENJPEG=openjpeg2

    ${POPPLER_CONFIGURE_ARGUMENTS}
)

