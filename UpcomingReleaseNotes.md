- Update NDK to 23.2.8568313 (last to support sdk level 16)

- Remove deprecated pdf2htmlEX_exe interface.
pdf2htmlEX_exe had to be removed, because it required pdf2htmlEX (not -Android) to be built as a shared library.
pdf2htmlEX (not -Android) built as a static library can be included in pdf2htmlEX-Android.so, which allows optimizing a lot of unused code away.
Shared library version was ~14 megs, static library version is ~7 megs.

- Remove deprecated NoForking mode
- Add BuildConfig.VERSION_NAME

- Implement public static String generateOutputFilename(String inputFilename), which removes .pdf suffix and adds .html suffix.

Rename following parameters:
- setOutline to setProcessOutline
- setBackgroundFormat to setBackgroundImageFormat

Expose following upstream pdf2htmlEX parameters to downstream users:
- setOutputHtml
- setFirstPage
- setLastPage
- setZoomRatio
- setFitWidth
- setFitHeight
- setUseCropBox
- setDPI
- setEmbedCSS
- setEmbedFont
- setEmbedImage
- setEmbedJavascript
- setEmbedOutline
- setSplitPages
- setProcessNonText
- setProcessOutline
- setProcessAnnotation
- setProcessForm
- setPrinting
- setFallback
- setEmbedExternalFont
- setFontFormat
- setDecomposeLigature
- setAutoHint
- setStretchNarrowGlyph
- setSqueezeWideGlyph
- setOverrideFstype
- setProcessType3
- setHorizontalEpsilon
- setVerticalEpsilon
- setSpaceThreshold
- setFontSizeMultiplier
- setSpaceAsOffset
- setToUnicode
- setOptimizeText
- setCorrectTextVisibility
- setCoveredTextDPI
- setBackgroundImageFormat
- setSVGNodeCountLimit
- setDebug
- setProof
- setQuiet
