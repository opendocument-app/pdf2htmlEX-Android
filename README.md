# Android port of [pdf2htmlEX](https://github.com/pdf2htmlEX/pdf2htmlEX)

![Build](https://github.com/ViliusSutkus89/pdf2htmlEX-Android/workflows/Build/badge.svg)
[![Download](https://api.bintray.com/packages/viliussutkus89/maven-repo/pdf2htmlex-android/images/download.svg)](https://bintray.com/viliussutkus89/maven-repo/pdf2htmlex-android/_latestVersion)

### Goals:
* Providing easy to use interface for downstream users.  
Library is consumed through gradle and used through a Java class, which provides a method to perform conversion.
* Keeping device requirements low.  
Current versions of NDK support building for Android-16 (Jelly Bean) and newer.  
Supported ABIs: armeabi-v7a, arm64-v8a, x86, x86_64.
* Keeping installed footprint low.  
Sample application consumes under 30MB.

### How to install:
[android-sample-app/app/build.gradle](android-sample-app/app/build.gradle) contains code to load the library as a dependency in Gradle.
```gradle
dependencies {
    implementation 'com.viliussutkus89:pdf2htmlex-android:0.18.6'
}
```

pdf2htmlEX-Android is distributed using [JCenter](https://jcenter.bintray.com) Maven repository.  
It needs be added to [top level build.gradle](android-sample-app/build.gradle)
```gradle
allprojects {
  repositories {
      jcenter()
  }
}
```

### Usage:
Library is interfaced through Java.
```Java
import com.viliussutkus89.android.pdf2htmlex.pdf2htmlEX;
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

### Problem scope:
pdf2htmlEX depends on 4 libraries:
* Cairo
* FontForge
* FreeType
* Poppler

These libraries also have dependencies of their own. FontForge requires FreeType, libjpeg, zlib, et cetera.
Full list of packages and patches to build them is included in [packages](/dependency-builder/src/main/cpp/packages/) folder.

### CMake Superbuild pattern
[DependencyBuilder](/dependency-builder/src/main/cpp/CMakeLists.txt) is a meta project which builds it's
[ExternalProjects](https://cmake.org/cmake/help/latest/module/ExternalProject.html) (Cairo, FontForge, et cetera).
Current implementation supports building projects which are based on [Autotools](/dependency-builder/src/main/cpp/EPAutotools.cmake), [CMake](/dependency-builder/src/main/cpp/EPCMake.cmake) and [Meson](/dependency-builder/src/main/cpp/EPMeson.cmake).

[pdf2htmlEX-Android](pdf2htmlEX/src/main/cpp/CMakeLists.txt) consumes previously built libraries and provides a Java wrapper to call pdf2htmlEX.

### [Sample application](/android-sample-app)
Example demonstrates how to convert PDF files to HTML and either open the result in browser or save to storage.
Storage Access Framework (SAF) is used for file management, it requires API level 19 (KitKat).
Debug build of sample application is available in [Releases Page](https://github.com/ViliusSutkus89/pdf2htmlEX-Android/releases)

### Tools to build from source:
* Meson Build system
* pkg-config
* CMake-3.10.2
* ndk-20.1.5948944
* gettext
* gperf

