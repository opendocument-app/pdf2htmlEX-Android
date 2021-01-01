include_guard(GLOBAL)

# We do not build zlib, only provide pkg-config.pc file, so that the library could be found easier.
ExternalProjectFiletree(zlib)

