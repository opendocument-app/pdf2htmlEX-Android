## Run unit tests on released AAR

Copy unit tests and other required files from main project
```sh
./copyFilesFromMainProject.sh
```

Add a dependency to released AAR in [aar-instrumented-tester/pdf2htmlEX/build.gradle](aar-instrumented-tester/pdf2htmlEX/build.gradle)
```Groovy
dependencies {
...
implementation 'com.viliussutkus89:pdf2htmlex-android:0.18.3'
...
}
```

Local .aar file can be used to, but it needs a complete list of dependencies
```Groovy
...
files('libs/pdf2htmlex-android-release.aar')
implementation 'com.viliussutkus89:tmpfile-android:1.0.2'
...
```
