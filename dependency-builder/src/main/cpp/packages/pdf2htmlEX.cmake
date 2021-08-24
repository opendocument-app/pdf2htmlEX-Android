include_guard(GLOBAL)

ExternalProjectCMake(pdf2htmlEX
  DEPENDS cairo Fonts-SymbolAndZapfDingbats freetype libfontforge poppler

  URL https://github.com/pdf2htmlEX/pdf2htmlEX/archive/v0.18.7-poppler-0.81.0.tar.gz
  URL_HASH SHA256=510d9fc2175fda1ab6968c389fa78d7078183583a543019f4eefe09b8373c6e4
  LICENSE_FILES LICENSE LICENSE_GPLv3
)

