message(FATAL_ERROR "Do not build this. Use NOOP libintl")

include_guard(GLOBAL)

# gettext doesn't provide pkg-config .pc
# Check if build is needed, before calling to EPAutotools

# We only building gettext for libintl.a, so that is what we are checking
if (EXISTS ${THIRDPARTY_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}intl${CMAKE_STATIC_LIBRARY_SUFFIX})
  return()
endif ()

ExternalProjectAutotools(gettext
  DEPENDS iconv libxml-2.0
  URL https://ftp.gnu.org/pub/gnu/gettext/gettext-0.20.1.tar.gz
  URL_HASH SHA256=66415634c6e8c3fa8b71362879ec7575e27da43da562c798a8a2f223e6e47f5c
  CONFIGURE_ARGUMENTS
    --disable-java
    --disable-libasprintf
    --disable-curses
    --disable-namespacing
    --disable-openmp
    --disable-acl
  EXTRA_ARGUMENTS
    UPDATE_COMMAND
    # libcroco/cr-statement.c:2661:32: error: format string is not a string literal (potentially insecure) [-Werror,-Wformat-security]
                #fprintf (a_fp, str) ;
    # gettext wtf? Why U doing this???
    ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixGettextSource.sh
    ${CMAKE_CURRENT_BINARY_DIR}/gettext-prefix/src/gettext/

    LOG_UPDATE 1
)
