/*
 * pdf2htmlEX.cc
 *
 * Copyright (C) 2019 Vilius Sutkus'89
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
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
Java_com_viliussutkus89_pdf2htmlex_pdf2htmlEX_set_1env_1values_1for_1fontforge(JNIEnv *env,
                                                                               jobject,
                                                                               jstring homedir_,
                                                                               jstring tmpdir_,
                                                                               jstring username_) {
  const char * homedir = env->GetStringUTFChars(homedir_, nullptr);
  const char * tmpdir = env->GetStringUTFChars(tmpdir_, nullptr);
  const char * username = env->GetStringUTFChars(username_, nullptr);

  setenv("HOME", homedir, 0);
  setenv("TMPDIR", tmpdir, 0);
  setenv("USER", username, 0);

  env->ReleaseStringUTFChars(homedir_, homedir);
  env->ReleaseStringUTFChars(tmpdir_, tmpdir);
  env->ReleaseStringUTFChars(username_, username);
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_viliussutkus89_pdf2htmlex_pdf2htmlEX_call_1pdf2htmlEX(JNIEnv *env, jobject,
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
  int retVal;
  vector_to_char_pp(args, &argc, &argv);

  retVal = pdf2htmlEX_main(argc, argv);

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
