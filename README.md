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

# Below is the non Android related info


# ![](https://pdf2htmlEX.github.io/pdf2htmlEX/images/pdf2htmlEX-64x64.png) pdf2htmlEX 

[![Build Status](https://travis-ci.org/pdf2htmlEX/pdf2htmlEX.svg?branch=master)](https://travis-ci.org/pdf2htmlEX/pdf2htmlEX)

# Differences from upstream pdf2htmlEX:

This is my branch of pdf2htmlEX which aims to allow an open collaboration to help keep the project active. A number of changes and improvements have been incorperated from other forks:

* Lots of bugs fixes, mostly of edge cases
* Integration of latest Cairo code
* Out of source building
* Rewritten handling of obscured/partially obscured text - now much more accurate
* Some support for transparent text
* Improvement of DPI settings - clamping of DPI to ensure output graphic isn't too big

`--correct-text-visibility` tracks the visibility of 4 sample points for each character (currently the 4 corners of the character's bounding box, inset slightly) to determine visibility.
It now has two modes. 1 = Fully occluded text handled (i.e. doesn't get put into the HTML layer). 2 = Partially occluded text handled.

The default is now "1", so fully occluded text should no longer show through. If "2" is selected then if the character is partially occluded it will be drawn in the background layer. In this case, the rendered DPI of the page will be automatically increased to `--covered-text-dpi` (default: 300) to reduce the impact of rasterized text.

For maximum accuracy I strongly recommend using the output options: `--font-size-multiplier 1 --zoom 25`. This will circumvent rounding errors inside web browsers. You will then have to scale down the resulting HTML page using an appropriate "scale" transform.

If you are concerned about file size of the resulting HTML, then I recommend patching fontforge to prevent it writing the current time into the dumped fonts, and then post-process the pdf2htmlEX data to remove duplicate files - there will usually be many duplicate background images and fonts.


>一图胜千言<br>A beautiful demo is worth a thousand words

- **Bible de Genève, 1564** (fonts and typography): [HTML](https://pdf2htmlEX.github.io/pdf2htmlEX/demo/geneve.html) / [PDF](https://github.com/raphink/geneve_1564/releases/download/2015-07-08_01/geneve_1564.pdf)
- **Cheat Sheet** (math formulas): [HTML](https://pdf2htmlEX.github.io/pdf2htmlEX/demo/cheat.html) / [PDF](http://www.tug.org/texshowcase/cheat.pdf)
- **Scientific Paper** (text and figures): [HTML](https://pdf2htmlEX.github.io/pdf2htmlEX/demo/demo.html) / [PDF](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.148.349&rep=rep1&type=pdf)
- **Full Circle Magazine** (read while downloading): [HTML](https://pdf2htmlEX.github.io/pdf2htmlEX/demo/issue65_en.html) / [PDF](http://dl.fullcirclemagazine.org/issue65_en.pdf)
- **Git Manual** (CJK support): [HTML](https://pdf2htmlEX.github.io/pdf2htmlEX/demo/chn.html) / [PDF](http://files.cnblogs.com/phphuaibei/git%E6%90%AD%E5%BB%BA.pdf)

pdf2htmlEX renders PDF files in HTML, utilizing modern Web technologies.
Academic papers with lots of formulas and figures? Magazines with complicated layouts? No problem!

pdf2htmlEX is also an [online publishing tool](https://pdf2htmlEX.github.io/pdf2htmlEX/doc/tb108wang.html) which is flexible for many different use cases. 

Learn more about [who](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Use-Cases) and [why](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Introduction) should use pdf2htmlEX.

### Features

* Native HTML text with precise font and location.
* Flexible output: all-in-one HTML or on demand page loading (needs JavaScript).
* Moderate file size, sometimes even smaller than PDF.
* Supporting links, outlines (bookmarks), printing, SVG background, Type 3 fonts and [more...](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Feature-List)

[Compare to others](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Comparison)

### Portals

 * [:house:Wiki Home](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki)
 * [Download](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Download) & [Building](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Building)
 * [Quick Start](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Quick-Start)
 * [Report Issues / Ask for Help](https://github.com/pdf2htmlEX/pdf2htmlEX/blob/master/CONTRIBUTING.md#guidance)
 * [:question:FAQ](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/FAQ)
 * [:envelope:Mailing List](https://groups.google.com/forum/#!forum/pdf2htmlex)
 * [:mahjong:中文邮件列表](https://groups.google.com/forum/#!forum/pdf2htmlex-cn)

### LICENSE

pdf2htmlEX, as a whole package, is licensed under GPLv3+.
Some resource files are released with relaxed licenses, read `LICENSE` for more details.

### Acknowledgements

pdf2htmlEX is made possible thanks to the following projects:

* [poppler](http://poppler.freedesktop.org/)
* [Fontforge](http://fontforge.org/)

pdf2htmlEX is inspired by the following projects:

* pdftohtml from poppler 
* MuPDF
* PDF.js
* Crocodoc
* Google Doc

#### Special Thanks

* Hongliang Tian
* Wanmin Liu 
