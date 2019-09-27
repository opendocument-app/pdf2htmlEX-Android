include_guard(GLOBAL)

# libffi-3.2.1 fails to build on armeabi-v7a ABI
# https://github.com/libffi/libffi/issues/478
# Use 3.3-rc0

ExternalProjectAutotools(libffi
  URL https://github.com/libffi/libffi/releases/download/v3.3-rc0/libffi-3.3-rc0.tar.gz
  URL_HASH SHA256=403d67aabf1c05157855ea2b1d9950263fb6316536c8c333f5b9ab1eb2f20ecf
)

