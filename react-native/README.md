# React Native and Motoko integration

## Notes
1. There's no support for Wasm on Android and iOS (the former uses a JavaScript engine that doesn't support WebAssembly and react-native-v8 fails when calling WASI.init(), and the latter only works on the iPhone Emulator and is disabled on the real hardware since iOS 15), we had to use wasm2js from https://github.com/WebAssembly/binaryen to be able to communicate with the Motoko lib

## Example code
    import * as Lib from './a-motoko-lib';
    const helper = new MoHelper(Lib);
    Lib._start();
    ...
    const res = Lib.greet(0, helper.stringToText(name));
    Alert.alert('greet() result', helper.textToString(res));
