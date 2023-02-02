Flutter/Dart and Motoko integration

1. Follow https://github.com/dart-lang/wasm/blob/main/flutter_wasm/README.md to install the libraries needed
2. Clone the https://github.com/dart-lang/wasm repository to build on Linux or https://github.com/av1ctor/wasm to build on Windows
3. Build using Visual Studio Code

Notes:
1. flutter_wasm has no support por iOS, only for Android
2. flutter_wasm will take ages to build the wasmer for Android (the build also failed on Linux Ubuntu because it tries to link to Ubuntu libraries with the Android ones)
  
