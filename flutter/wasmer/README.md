# Flutter/Dart and Motoko integration (Wasmer version)

1. Follow https://github.com/dart-lang/wasm/blob/main/flutter_wasm/README.md to install the libraries needed
2. Clone the https://github.com/dart-lang/wasm repository to build on Linux or https://github.com/av1ctor/wasm to build on Windows
3. Install the Android SDK Platform 31 (Android 12.0 S) and the Android NDK 21.4.7075529 (anything above that will fail because there's no /plataforms directory anymore on the NDK)
4. Start the Android Emulator from Android Studio (must be a x86_64 image)
5. Build using Visual Studio Code (select the Android target) and run: flutter run

## Notes
1. flutter_wasm has no support por iOS, only for Android
2. flutter_wasm will take ages to build the wasmer for Android (the build also failed on Linux Ubuntu because it tries to link to Ubuntu libraries with the Android ones)
  
## Example code

    final wasm = await loadWasm();
    if (!helper.load(wasm)) {
      return;
    }
    if (!helper.instanciate()) {
      return;
    }
    
    var greet = helper.lookupFunction("greet");
    var res = greet(0, helper.stringToText(name));
    print(helper.textToString(res));
