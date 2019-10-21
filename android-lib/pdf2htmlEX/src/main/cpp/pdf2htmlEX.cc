#include <jni.h>
#include <string>
#include <vector>
//#include "pdf2htmlEX.h"

// Creating char ** by hand is rather annoying.
// I'll rather take vector<string> and convert it before calling.
void vector_to_char_pp(const std::vector<const std::string> & input, int * argc, char *** argv) {
  *argv = nullptr;
  *argc = 0;

  size_t sz = input.size();
  if (sz == 0) {
    return;
  }
  char ** output = new char *[sz];
  int i = 0;
  for (const std::string & s: input) {
    size_t len = s.length();
    output[i] = new char[len+1];
    output[i][len] = '\0';
    strncpy(output[i], s.c_str(), len);
    i++;
  }

  *argc = static_cast<int>(sz);
  *argv = output;
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_pdf2htmlex_android_1sample_1app_MainActivity_setenv(JNIEnv *env,
                                                                            jobject,
                                                                            jstring homedir_,
                                                                            jstring tmpdir_
                                                                            ) {
    const char * homedir = env->GetStringUTFChars(homedir_, 0);
    const char * tmpdir = env->GetStringUTFChars(tmpdir_, 0);

    setenv("HOME", homedir, 1);
    setenv("TMPDIR", tmpdir, 1);
    setenv("USER", "HELLO!!", 1);

    FILE *x = tmpfile();

    env->ReleaseStringUTFChars(tmpdir_, tmpdir);
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_viliussutkus89_pdf2htmlex_android_1sample_1app_MainActivity_call_1pdf2htmlEX(JNIEnv *env,
                                                                                      jobject,
                                                                                      jstring dataDir_,
                                                                                      jstring popplerDir_,
                                                                                      jstring tmpDir_,
                                                                                      jstring inputFile_,
                                                                                      jstring outputFile_) {
    const char *dataDir = env->GetStringUTFChars(dataDir_, 0);
    const char *popplerDir = env->GetStringUTFChars(popplerDir_, 0);
    const char *tmpDir = env->GetStringUTFChars(tmpDir_, 0);
    const char *inputFile = env->GetStringUTFChars(inputFile_, 0);
    const char *outputFile = env->GetStringUTFChars(outputFile_, 0);


    std::vector<const std::string> args = {
        "libpdf2htmlEX.so",
        "--data-dir", dataDir,
        "--poppler-data-dir", popplerDir,
        "--tmp-dir", tmpDir,
//        "--tounicode", "1",
//        "--correct-text-visibility", "0",
//        "--font-format", "svg",
//        "--auto-hint", "1",
//        "--embed-image", "0",
//        "--process-nontext", "0",
//        "--process-annotation", "1",
//        "--process-form", "1",
//        "--fallback", "1",
//        "--proof", "1",
        inputFile, outputFile
    };

    int argc;
    char ** argv;
    vector_to_char_pp(args, &argc, &argv);

    //int retVal = pdf2htmlEX_main(argc, argv);
    int retVal = 0;
    
    for (int i = 0; i < argc; i++) {
        delete[] argv[i];
    }
    delete argv;

    env->ReleaseStringUTFChars(dataDir_, dataDir);
    env->ReleaseStringUTFChars(popplerDir_, popplerDir);
    env->ReleaseStringUTFChars(tmpDir_, tmpDir);
    env->ReleaseStringUTFChars(inputFile_, inputFile);
    env->ReleaseStringUTFChars(outputFile_, outputFile);
    return retVal;
}
