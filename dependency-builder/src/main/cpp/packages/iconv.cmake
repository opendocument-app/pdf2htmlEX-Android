# ANDROID-28+ has iconv built in.
if(ANDROID_NATIVE_API_LEVEL GREATER_EQUAL 28)
  SET(iconv_FOUND 1)
endif()

include_guard(GLOBAL)

ExternalProjectAutotools(iconv
  URL https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz
  URL_HASH SHA256=e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04
)
