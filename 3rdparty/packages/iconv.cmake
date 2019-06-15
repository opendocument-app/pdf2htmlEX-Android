include_guard(GLOBAL)

# iconv not needed on ANDROID-28+
IF (ANDROID_NATIVE_API_LEVEL GREATER_EQUAL 28)
  return()
endif()

# libiconv doesn't provide pkg-config .pc
# Check if build sneeded, before calling to EPAutotools
if (EXISTS ${THIRDPARTY_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}iconv${CMAKE_STATIC_LIBRARY_SUFFIX})
  return()
endif()

ExternalProjectAutotools(iconv
  URL https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz
  URL_HASH SHA256=e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04
)
