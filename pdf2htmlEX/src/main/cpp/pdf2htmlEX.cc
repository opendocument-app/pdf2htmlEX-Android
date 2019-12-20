/*
 * pdf2htmlEX.cc
 *
 * pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
 * Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
 *
 * Copyright (c) 2019 Vilius Sutkus <ViliusSutkus89@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <cstdlib>
#include <string>
#include <vector>
#include <jni.h>
#include <unistd.h>
#include <sys/wait.h>
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
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_pdf2htmlEX_set_1environment_1value(JNIEnv *env, jobject,
                                                                          jstring key_,
                                                                          jstring value_) {
    const char * key = env->GetStringUTFChars(key_, nullptr);
    const char * value = env->GetStringUTFChars(value_, nullptr);
    setenv(key, value, 1);
    env->ReleaseStringUTFChars(key_, key);
    env->ReleaseStringUTFChars(value_, value);
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_pdf2htmlEX_call_1pdf2htmlEX(JNIEnv *env, jobject,
                                                               jstring dataDir_,
                                                               jstring popplerDir_, jstring tmpDir_,
                                                               jstring inputFile_,
                                                               jstring outputFile_) {
  const char *dataDir = env->GetStringUTFChars(dataDir_, nullptr);
  const char *popplerDir = env->GetStringUTFChars(popplerDir_, nullptr);
  const char *tmpDir = env->GetStringUTFChars(tmpDir_, nullptr);
  const char *inputFile = env->GetStringUTFChars(inputFile_, nullptr);
  const char *outputFile = env->GetStringUTFChars(outputFile_, nullptr);

  std::vector<const std::string> args = {
    "libpdf2htmlEX",
    "--data-dir", dataDir,
    "--poppler-data-dir", popplerDir,
    "--tmp-dir", tmpDir,
    inputFile, outputFile
  };

  int argc;
  char **argv;
  int retVal = -1;

  vector_to_char_pp(args, &argc, &argv);

  // https://github.com/ViliusSutkus89/pdf2htmlEX-Android/issues/4
  // Upstream library is actually an executable, not a library.
  // May have some global state, initialized as static constructor, poisoned after first use.
  // Workaround: fork process before use.
  pid_t pid = fork();
  if (0 == pid) {
    retVal = pdf2htmlEX_main(argc, argv);
    exit(retVal);
  }
  else if (0 < pid) {
    int wstatus;
    waitpid(pid, &wstatus, 0);
    if (WIFEXITED(wstatus)) {
      retVal = WEXITSTATUS(wstatus);
    }
  }

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
