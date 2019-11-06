# Android port of [pdf2htmlEX](https://github.com/pdf2htmlEX/pdf2htmlEX)

### Goals:
* Providing easy to use interface for downstream users.  
Library is consumed as .aar file through gradle and used through a Java class, which provides a method to perform conversion.
* Keeping device requirements low.  
Current versions of NDK support building for Android-16 (Jelly Bean) and newer.  
Supported ABIs: armeabi-v7a, arm64-v8a, x86, x86_64.
* Keeping installed footprint low.  
Sample application consumes under 30MB.

### Usage:
Download pdf2htmlEX.aar and place it to libs folder.
Consume it as a dependency in [build.gradle](android-sample-app/app/build.gradle)

```gradle
dependencies {
  implementation files('libs/pdf2htmlEX.aar')
}
```

Library is interfaced through Java.
```Java
import com.viliussutkus89.android.pdf2htmlex.pdf2htmlEX;
...
java.io.File inputPdf = new java.io.File(getFilesDir(), "my.pdf");
pdf2htmlEX converter = new pdf2htmlEX(getApplicationContext());
java.io.File outputHTML = converter.convert(inputPdf);
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

### Tools to build from source:
* Meson Build system
* pkg-config
* gperf
* CMake-3.10.2
* ndk-20.0.5594570

#### HOWTO build library:
```sh
./dobuild
```
