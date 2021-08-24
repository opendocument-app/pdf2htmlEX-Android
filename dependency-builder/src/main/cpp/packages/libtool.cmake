# libtool does not have pkg-config.pc. Check if libltdl.a exists.
if (EXISTS ${THIRDPARTY_PREFIX}/lib/libltdl.a)
  SET(libtool_FOUND 1)
endif()

include_guard(GLOBAL)

ExternalProjectAutotools(libtool
  URL ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz
  URL_HASH SHA512=a6eef35f3cbccf2c9e2667f44a476ebc80ab888725eb768e91a3a6c33b8c931afc46eb23efaee76c8696d3e4eed74ab1c71157bcb924f38ee912c8a90a6521a4
  LICENSE_FILES COPYING
)

