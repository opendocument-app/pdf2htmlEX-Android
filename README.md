# pdf2htmlEX Android port
### Goals:
* Running on Android as a JNI library
* No excessive device requirements. NDK supports Android-16 (Jelly Bean) and newer. 
* Small footprint (Installed App size). Current (0.15.1) sample app with libpdf2htmlEX.so bundled installed on Android-19 armeabi-v7a consumes ~25MB.

### Sample app
* Open PDF, convert to HTML and either open it in browser or save to device.
* No permissions nagging. App opens and saves user files using native file APIs. Current implementation requires API level 19 (KitKat).

### Tools to build from source:
* Meson
* Ninja
* CMake-3.10.2
* pkg-config
* Android NDK

### Project problem scope:
pdf2htmlEX depends on 4 libraries:
* Cairo
* FontForge
* FreeType
* Poppler

None of them are shipped on Android devices so they have to be built from source.

### CMake superbuild pattern (3rdparty/CMakeLists.txt and CMakeListst.txt)
[3rdparty/CMakeLists.txt](3rdparty/CMakeLists.txt) is a meta project which builds it's [ExternalProject's](https://cmake.org/cmake/help/latest/module/ExternalProject.html) (Cairo, Fontforge, et cetera). Current implementation supports building projects which are based on [Autotools](3rdparty/EPAutotools.cmake), [CMake](3rdparty/EPCMake.cmake) and [Meson](3rdparty/EPMeson.cmake).

ExternalProjects can have dependencies. FontForge requires FreeType, libjpeg, zlib, et cetera. Dependencies of dependencies can have dependencies. ExternalProject is a CMake target, thus allowing CMake target dependency resolving.

[CMakeListst.txt](CMakeListst.txt) builds "regular" shared library libpdf2htmlEX.so.

### HOWTO build:
```sh
./dobuild
```

### What does dobuild script do?
[android-libpdf2htmlex](android-libpdf2htmlex) is a barebones Android gradle project that builds [CMakeLists.txt](CMakeLists.txt)
[./dobuild](dobuild)
1) Uses android-libpdf2htmlex to generate a very similar project android-3rdparty which builds [3rdparty/CMakeLists.txt](3rdparty/CMakeLists.txt)
2) Calls gradle on android-3rdparty and then cmake --build on each ABI (armeabi-v7a, arm64-v8a, x86, x86_64) and build type (debug, release). All 8 CMake calls are in parallel, expect heavy load, because of dependency amount.
3) Calls gradle and CMake on android-libpdf2htmlex and packages result (libpdf2htmlEX.so, .css files) in pdf2htmlEX-release.tar and pdf2htmlEX-debug.tar
4) Extracts -release tar into android-sample-app
5) Calls gradle on android-sample-app

### HOWTO integrate libpdf2htmlEX to my App:

```sh
tar --extract --file pdf2htmlEX-release.tar --directory=android-sample-app/app/src/main jniLibs assets
```
Link your native library against libpdf2htmlEX.so
```CMake
include(${CMAKE_SOURCE_DIR}/../jniLibs/pdf2htmlEX.cmake)
target_link_libraries(native-lib pdf2htmlEX)
```

