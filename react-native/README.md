# React Native and Motoko integration
1. Run: npm install
2. Generate the APK for Android following this guide: https://reactnative.dev/docs/0.70/signed-apk-android
3. Run on the iOS Simulator: https://reactnative.dev/docs/0.70/running-on-simulator-ios (sorry, I don't have an iPhone to test)

## Notes
1. There's no support for Wasm on Android and iOS (the former uses a JavaScript engine that doesn't support WebAssembly and react-native-v8 fails when calling WASI.init(), and the latter only works on the iPhone Emulator and is disabled on the real hardware since iOS 15), we had to use wasm2js from https://github.com/WebAssembly/binaryen to be able to communicate with the Motoko lib

## Example code
    import * as Lib from './a-motoko-lib';
    const helper = new MoHelper(Lib);
    Lib._start();
    ...
    const res = Lib.greet(0, helper.stringToText(name));
    Alert.alert('greet() result', helper.textToString(res));
