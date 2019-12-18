#include <jni.h>
#include <fontconfig/fontconfig.h>

extern "C"
JNIEXPORT jstring JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_FontconfigInstrumentedTests_getFontFilenameFromFontconfig(
        JNIEnv *env, jclass, jstring pattern_) {
  const char * pattern = env->GetStringUTFChars(pattern_, nullptr);
  FcFontSet	*fs = FcFontSetCreate();
  FcPattern *pat = FcNameParse (reinterpret_cast<const FcChar8 *>(pattern));

  env->ReleaseStringUTFChars(pattern_, pattern);

  FcConfigSubstitute (0, pat, FcMatchPattern);
  FcDefaultSubstitute (pat);
  FcResult result;
  FcPattern *match = FcFontMatch (0, pat, &result);
  if (match)
    FcFontSetAdd (fs, match);
  FcPatternDestroy (pat);

  jstring matchedFilename = nullptr;

  if (fs) {
    for (int j = 0; j < fs->nfont; j++) {
      FcPattern *font = FcPatternFilter (fs->fonts[j], 0);
      FcChar8 *s = FcPatternFormat (font, reinterpret_cast<const FcChar8 *>("%{file|basename}"));
      if (s) {
        matchedFilename = env->NewStringUTF(reinterpret_cast<char *>(s));
        FcStrFree (s);
      }
      FcPatternDestroy (font);
    }
    FcFontSetDestroy (fs);
  }
  FcFini ();
  return matchedFilename ? matchedFilename : env->NewStringUTF("");
}

