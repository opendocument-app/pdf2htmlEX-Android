# [pdf2htmlEX](https://github.com/pdf2htmlEX/pdf2htmlEX) library port for Android

[![build](https://github.com/opendocument-app/pdf2htmlEX-Android/actions/workflows/build.yml/badge.svg)](https://github.com/opendocument-app/pdf2htmlEX-Android/actions/workflows/build.yml)
[![Maven Central](https://img.shields.io/maven-central/v/app.opendocument/pdf2htmlex-android.svg?label=Maven%20Central)](https://search.maven.org/search?q=g:app.opendocument%20AND%20a:pdf2htmlex-android)

### Used by:
- [Documenter](https://github.com/ViliusSutkus89/Documenter) on [Google Play](https://play.google.com/store/apps/details?id=com.viliussutkus89.documenter) - reference application for pdf2htmlEX-Android and wvWare-Android libraries.
- [OpenDocument.droid](https://github.com/opendocument-app/OpenDocument.droid) on [Google Play](https://play.google.com/store/apps/details?id=at.tomtasche.reader) - It's Android's first OpenOffice Document Reader!
- Now defunct [pdf2htmlEX-Android sample application](https://github.com/ViliusSutkus89/pdf2htmlEX-Android/tree/v0.18.18/application).

### C++ runtime dependency:
[Using prebuilt libraries](https://developer.android.com/ndk/guides/common-problems#using_mismatched_prebuilt_libraries) is less problematic if all the libraries used in the application are:
* Built with the same major version of toolchain - ndk-26
* Linked against shared C++ STL - `android.defaultConfig.externalNativeBuild.cmake.arguments "-DANDROID_STL=c++_shared"` in app's (and all JNI dependencies) build.gradle.

### How to install:
pdf2htmlEX-Android is distributed through MavenCentral. Add a dependency in `build.gradle`:
```groovy
dependencies {
    implementation("app.opendocument:pdf2htmlex-android:0.18.25")
}
```

### Usage:
Library is interfaced through Java.
```Java
import app.opendocument.android.pdf2htmlex.pdf2htmlEX;
...
java.io.File inputPdf = new java.io.File(getFilesDir(), "my.pdf");
java.io.File outputHTML = new pdf2htmlEX(getApplicationContext()).setInputPDF(inputPdf).convert();
```

Encrypted PDF documents need a password to be decrypted.

Either owner (admin):
```Java
java.io.File outputHTML = new pdf2htmlEX(getApplicationContext()).setInputPDF(inputPdf).setOwnerPassword("owner-password").convert();
```
or user password can be used:
```Java

java.io.File outputHTML = new pdf2htmlEX(getApplicationContext()).setInputPDF(inputPdf).setUserPassword("user-password").convert();
```

Library needs Android Context to obtain path to cache directory and asset files, which are supplied in .aar.
