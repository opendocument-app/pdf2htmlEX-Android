include_guard(GLOBAL)

ExternalProjectMeson(harfbuzz
  DEPENDS cairo fontconfig freetype glib-2.0

  # Issue #65
#  https://github.com/harfbuzz/harfbuzz/releases/download/4.2.1/harfbuzz-4.2.1.tar.xz
#  bd17916513829aeff961359a5ccebba6de2f4bf37a91faee3ac29c120e3d7ee1

#  https://github.com/harfbuzz/harfbuzz/releases/download/3.4.0/harfbuzz-3.4.0.tar.xz
#  7158a87c4db82521fc506711f0c8864115f0292d95f7136c8812c11811cdf952

#  https://github.com/harfbuzz/harfbuzz/releases/download/3.3.2/harfbuzz-3.3.2.tar.xz
#  1c13bca136c4f66658059853e2c1253f34c88f4b5c5aba6050aba7b5e0ce2503

#  https://github.com/harfbuzz/harfbuzz/releases/download/3.3.0/harfbuzz-3.3.0.tar.xz
#  f6fb9f28d3df7c027f38b283ec28944fb9900ab2898b149c75c91c34c9c186e6

  URL https://github.com/harfbuzz/harfbuzz/releases/download/3.2.0/harfbuzz-3.2.0.tar.xz
  URL_HASH SHA256=0ada50a1c199bb6f70843ab893c55867743a443b84d087d54df08ad883ebc2cd

  # Meson tests don't really work when cross compiling
  CONFIGURE_ARGUMENTS -Dtests=disabled
)
