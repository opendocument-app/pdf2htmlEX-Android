include_guard(GLOBAL)

ExternalProjectAutotools(libxml-2.0
  DEPENDS iconv
  URL http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz
  URL_HASH SHA256=94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871
  CONFIGURE_ARGUMENTS --without-python
)
