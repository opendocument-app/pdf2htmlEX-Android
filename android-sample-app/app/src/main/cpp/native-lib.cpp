#include <jni.h>
#include <string>
#include <vector>
#include "pdf2htmlEX.h"

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
JNIEXPORT jint JNICALL
Java_com_viliussutkus89_pdf2htmlex_android_1sample_1app_MainActivity_call_1pdf2htmlEX(JNIEnv *env,
                                                                                      jobject instance,
                                                                                      jstring dataDir_,
                                                                                      jstring tmpDir_,
                                                                                      jstring inputFile_,
                                                                                      jstring outputFile_) {
    const char *dataDir = env->GetStringUTFChars(dataDir_, 0);
    const char *tmpDir = env->GetStringUTFChars(tmpDir_, 0);
    const char *inputFile = env->GetStringUTFChars(inputFile_, 0);
    const char *outputFile = env->GetStringUTFChars(outputFile_, 0);


    std::vector<const std::string> args = {
        "libpdf2htmlEX.so",
        "--data-dir", dataDir,
        "--tmp-dir", tmpDir,
        inputFile, outputFile
    };

    int argc;
    char ** argv;
    vector_to_char_pp(args, &argc, &argv);
    int retVal = pdf2htmlEX_main(argc, argv);
    for (int i = 0; i < argc; i++) {
        delete[] argv[i];
    }
    delete argv;

    env->ReleaseStringUTFChars(dataDir_, dataDir);
    env->ReleaseStringUTFChars(tmpDir_, tmpDir);
    env->ReleaseStringUTFChars(inputFile_, inputFile);
    env->ReleaseStringUTFChars(outputFile_, outputFile);
    return retVal;
}