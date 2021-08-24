include_guard(GLOBAL)

# Build errors for armeabi-v7a SIMD and Neon asm code.
if(ANDROID_ABI STREQUAL armeabi-v7a)
  SET(ARM32_CONFIG CONFIGURE_ARGUMENTS -Dneon=disabled -Darm-simd=disabled)
endif()

ExternalProjectMeson(pixman-1
  DEPENDS libpng glib-2.0
  URL https://cairographics.org/releases/pixman-0.40.0.tar.gz
  URL_HASH SHA512=063776e132f5d59a6d3f94497da41d6fc1c7dca0d269149c78247f0e0d7f520a25208d908cf5e421d1564889a91da44267b12d61c0bd7934cd54261729a7de5f
  LICENSE_FILES COPYING
  ${ARM32_CONFIG}
)
