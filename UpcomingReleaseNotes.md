- Update NDK to 23.2.8568313 (last to support sdk level 16)

- remove deprecated pdf2htmlEX_exe interface.
pdf2htmlEX_exe had to be removed, because it required pdf2htmlEX (not -Android) to be built as a shared library.
pdf2htmlEX (not -Android) built as a static library can be included in pdf2htmlEX-Android.so, which allows optimizing a lot of unused code away.
Shared library version was ~14 megs, static library version is ~7 megs.
