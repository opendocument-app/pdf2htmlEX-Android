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

IF (BUILD_ALL_3RDPARTY_UTILS_TO_CHECK_FOR_MISSING_SYMBOLS_IN_INCLUDED_LIBRARIES)
  SET(POPPLER_CONFIGURE_ARGUMENTS "-DBUILD_CPP_TESTS=ON -DENABLE_UTILS=ON")
ELSE()
  SET(POPPLER_CONFIGURE_ARGUMENTS "-DBUILD_CPP_TESTS=OFF -DENABLE_UTILS=OFF")
ENDIF ()

ExternalProjectCMake(poppler
  DEPENDS freetype libjpeg libopenjp2 glib-2.0 cairo libtiff-4 lcms2

  URL https://poppler.freedesktop.org/poppler-0.70.1.tar.xz
  URL_HASH SHA256=66972047d9ef8162cc8c389d7e7698291dfc9f2b3e4ea9a9f08ae604107451bd

  CONFIGURE_ARGUMENTS -DENABLE_XPDF_HEADERS=ON
    -DBUILD_GTK_TESTS=OFF -DBUILD_QT5_TESTS=OFF -DENABLE_QT5=OFF
    ${POPPLER_CONFIGURE_ARGUMENTS}

    EXTRA_ARGUMENTS
      # Manually link poppler against pixman-1 (if cairo used) and libjpeg (if libtiff used)
      UPDATE_COMMAND
        ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixPopplerSource.sh
        ${CMAKE_CURRENT_BINARY_DIR}/poppler-prefix/src/poppler/
      LOG_UPDATE 1

      # Fontforge uses libopenjp2 lcms2
      # But does not declare them in poppler.pc
      # Fix after install
      TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixPopplerInstall.sh ${THIRDPARTY_PREFIX}
      LOG_TEST 1
)
