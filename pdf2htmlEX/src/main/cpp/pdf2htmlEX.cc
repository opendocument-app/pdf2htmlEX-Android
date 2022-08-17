/*
 * pdf2htmlEX.cc
 *
 * pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
 * Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
 *
 * Copyright (c) 2019, 2022 ViliusSutkus89.com
 *
 * pdf2htmlEX-Android is free software: you can redistribute it and/or modify
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

#include <jni.h>
#include <android/log.h>
#include "CCharGC.h"
#include "pdf2htmlEX.h"

#define retValOK 0
#define retValError 1
#define retValEncryptionError 2
#define retValCopyProtected 3

extern "C"
JNIEXPORT jlong JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_createNewConverterObject(JNIEnv *env, jclass,
                                                                                    jstring tmp_dir,
                                                                                    jstring data_dir,
                                                                                    jstring poppler_dir) {
    auto * pdf2htmlEX = new pdf2htmlEX::pdf2htmlEX();

    pdf2htmlEX->setTMPDir(CCharGC(env, tmp_dir).c_str());
    pdf2htmlEX->setDataDir(CCharGC(env, data_dir).c_str());
    pdf2htmlEX->setPopplerDataDir(CCharGC(env, poppler_dir).c_str());

    return (jlong) pdf2htmlEX;
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_dealloc(JNIEnv *, jclass, jlong converter) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    delete pdf2htmlEX;
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_convert(JNIEnv *, jclass, jlong converter) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    try {
        pdf2htmlEX->convert();
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

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setInputFile(JNIEnv *env, jclass, jlong converter,
                                                                        jstring input_file) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setInputFilename(CCharGC(env, input_file).c_str());
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setOutputFile(JNIEnv *env, jclass, jlong converter,
                                                                         jstring output_file) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setOutputFilename(CCharGC(env, output_file).c_str());
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setOwnerPassword(JNIEnv *env, jclass, jlong converter,
                                                                            jstring owner_password) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setOwnerPassword(CCharGC(env, owner_password).c_str());
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setUserPassword(JNIEnv *env, jclass, jlong converter,
                                                                           jstring user_password) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setUserPassword(CCharGC(env, user_password).c_str());
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setOutline(JNIEnv *env, jclass, jlong converter,
                                                                      jobject enable) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setProcessOutline(enable);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setDrm(JNIEnv *env, jclass, jlong converter,
                                                                  jobject enable) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setDRM(enable);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setEmbedFont(JNIEnv *, jclass, jlong converter,
                                                                        jobject embed) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setEmbedFont(embed);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setEmbedExternalFont(JNIEnv *, jclass, jlong converter,
                                                                                jobject embed) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setEmbedExternalFont(embed);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setProcessAnnotation(JNIEnv *, jclass, jlong converter,
                                                                                jobject process) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setProcessAnnotation(process);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_viliussutkus89_android_pdf2htmlex_NativeConverter_setBackgroundFormat(JNIEnv *env, jclass, jlong converter,
                                                                               jstring background_format) {
    auto * pdf2htmlEX = (pdf2htmlEX::pdf2htmlEX *) converter;
    pdf2htmlEX->setBackgroundImageFormat(CCharGC(env, background_format).c_str());
}
