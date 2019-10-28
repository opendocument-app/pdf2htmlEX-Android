include_guard(GLOBAL)

ExternalProjectCMake(pdf2htmlEX
  DEPENDS cairo freetype libfontforge poppler

  URL https://github.com/pdf2htmlEX/pdf2htmlEX/archive/v0.17.0-poppler-0.68.0-ubuntu-18.10.tar.gz
  URL_HASH SHA256=399ae174fde94c1c0a4d9e4a6d8356b600589a2f33aef4091a0dd94516d2489f
)

