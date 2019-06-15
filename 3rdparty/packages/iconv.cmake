include_guard(GLOBAL)

# libiconv doesn't provide pkg-config .pc
# Check if build sneeded, before calling to EPAutotools
find_package(Iconv QUIET)

# Android >= 28 provides iconv
IF ((NOT Iconv_FOUND) AND NOT (ANDROID_NATIVE_API_LEVEL GREATER_EQUAL 28))
  ExternalProjectAutotools(iconv
    URL https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz
    #URL ${TARBALL_STORAGE}/libiconv-1.16.tar.gz
    URL_HASH SHA256=e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04
  )
endif()
