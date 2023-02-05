# Flutter/Dart and Motoko integration (Wasm3 version)

1. Install XCode from the App Store
2. Install the XCode command-line tools (see https://www.freecodecamp.org/news/install-xcode-command-line-tools/)
3. Install CocoaPods (see https://guides.cocoapods.org/using/getting-started.html) - Note: ruby and gem must be installed first
4. Install Flutter (see https://docs.flutter.dev/get-started/install/macos)
5. Run "flutter pub get" inside "[this-project-path]/flutter/wasm3" folder
6. Start the iOS simulator, running "open -a Simulator"
7. Run "flutter run" at the same folder as in item 5
8. If something fail, read also https://docs.flutter.dev/development/platform-integration/ios/c-interop

## Example code

    var helper = MoHelper(wasm);
    ...
    var greet = helper!.lookupFunction("greet");
    var res = helper!.callFunction(greet, [0, helper!.stringToText(name)]);
    print(helper!.textToString(res));
  
