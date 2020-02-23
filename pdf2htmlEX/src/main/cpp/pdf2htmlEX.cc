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
#include <jni.h>
#include <android/log.h>
#include "pdf2htmlEX.h"

#define retValOK 0
#define retValError 1
#define retValEncryptionError 2
#define retValCopyProtected 3

class CCharGC {
private:
    JNIEnv *env;
    jstring input;
    const char * cstr;

public:
    CCharGC(JNIEnv *env, jstring input) : env(env), input(input) {
      this->cstr = env->GetStringUTFChars(input, nullptr);
    }

    const char * c_str() const {
      return this->cstr;
    }

    bool isEmpty() const { return this->cstr[0] == '\0'; }

    ~CCharGC() {
      env->ReleaseStringUTFChars(this->input, this->cstr);
    }
};

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_pdf2htmlEX_set_1environment_1value(JNIEnv *env, jobject,
                                                                          jstring key_,
                                                                          jstring value_) {
    CCharGC key(env, key_);
    CCharGC value(env, value_);
    setenv(key.c_str(), value.c_str(), 1);
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_pdf2htmlEX_call_1pdf2htmlEX(JNIEnv *env, jobject,
                                                               jstring dataDir_,
                                                               jstring popplerDir_, jstring tmpDir_,
                                                               jstring inputFile_,
                                                               jstring outputFile_,
                                                               jstring ownerPassword_,
                                                               jstring userPassword_,
                                                               jboolean enableOutline,
                                                               jboolean enableDrm,
                                                               jstring backgroundFormat
							       ) {
  CCharGC dataDir(env, dataDir_);
  CCharGC popplerDir(env, popplerDir_);
  CCharGC tmpDir(env, tmpDir_);
  CCharGC inputFile(env, inputFile_);
  CCharGC outputFile(env, outputFile_);
  CCharGC ownerPassword(env, ownerPassword_);
  CCharGC userPassword(env, userPassword_);

  pdf2htmlEX::pdf2htmlEX converter;
  converter.setProcessOutline(enableOutline == JNI_TRUE);
  converter.setDRM(enableDrm == JNI_TRUE);
  converter.setDataDir(dataDir.c_str());
  converter.setPopplerDataDir(popplerDir.c_str());
  converter.setTMPDir(tmpDir.c_str());
  converter.setInputFilename(inputFile.c_str());
  converter.setOutputFilename(outputFile.c_str());

  if (!backgroundFormat.isEmpty()) {
    converter.setBackgroundImageFormat(backgroundFormat.c_str());
  }

  if (!ownerPassword.isEmpty()) {
    converter.setOwnerPassword(ownerPassword.c_str());
  }

  if (!userPassword.isEmpty()) {
    converter.setUserPassword(userPassword.c_str());
  }

  try {
    converter.convert();
  } catch (const pdf2htmlEX::EncryptionPasswordException & e) {
    return retValEncryptionError;
  } catch (const pdf2htmlEX::DocumentCopyProtectedException & e) {
    return retValCopyProtected;
  } catch (const pdf2htmlEX::ConversionFailedException & e) {
    __android_log_print(ANDROID_LOG_ERROR, "pdf2htmlEX-Android" , "%s", e.what());
    return retValError;
  }
  return retValOK;
}
