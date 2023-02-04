import 'dart:ffi'; // For FFI
import 'package:ffi/ffi.dart';
import 'dart:io'; // For Platform.isX

enum M3ValueType {
  none(0),
  i32(1),
  i64(2),
  f32(3),
  f64(4),
  unknown(5);

  const M3ValueType(this.value);
  final int value;
  static M3ValueType getByValue(num i) {
    return M3ValueType.values.firstWhere((x) => x.value == i);
  }
}

final DynamicLibrary wasm3Lib = Platform.isAndroid
    ? DynamicLibrary.open('libm3.so')
    : DynamicLibrary.process();

final Pointer<Void> Function() m3NewEnvironment = wasm3Lib
    .lookup<NativeFunction<Pointer<Void> Function()>>('m3_NewEnvironment')
    .asFunction();

final Pointer<Void> Function(
        Pointer<Void> environment, int stakeSize, Pointer<Void> userData)
    m3NewRuntime = wasm3Lib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(
                    Pointer<Void>, Uint32, Pointer<Void>)>>('m3_NewRuntime')
        .asFunction();

final int Function(Pointer<Void> environment, Pointer<Pointer<Void>> module,
        Pointer<Uint8> wasm, int len) m3ParseModule =
    wasm3Lib
        .lookup<
            NativeFunction<
                Int32 Function(Pointer<Void>, Pointer<Pointer<Void>>,
                    Pointer<Uint8>, Uint32)>>('m3_ParseModule')
        .asFunction();

final int Function(Pointer<Void> runtime, Pointer<Void> module) m3LoadModule =
    wasm3Lib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>, Pointer<Void>)>>(
            'm3_LoadModule')
        .asFunction();

final int Function(Pointer<Void> module) m3LinkWASI = wasm3Lib
    .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>("m3_LinkWASI")
    .asFunction();

final int Function(Pointer<Void> module) m3RunStart = wasm3Lib
    .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>('m3_RunStart')
    .asFunction();

final int Function(
        Pointer<Pointer<Void>> func, Pointer<Void> runtime, Pointer<Utf8> name)
    m3FindFunction = wasm3Lib
        .lookup<
            NativeFunction<
                Int32 Function(Pointer<Pointer<Void>>, Pointer<Void>,
                    Pointer<Utf8>)>>('m3_FindFunction')
        .asFunction();

final int Function(Pointer<Void> func, int argc, Pointer<Pointer<Void>> argptrs)
    m3Call = wasm3Lib
        .lookup<
            NativeFunction<
                Int32 Function(
                    Pointer<Void>, Uint32, Pointer<Pointer<Void>>)>>('m3_Call')
        .asFunction();

final int Function(Pointer<Void> func, int retc, Pointer<Pointer<Void>> reptrs)
    m3GetResults = wasm3Lib
        .lookup<
            NativeFunction<
                Int32 Function(Pointer<Void>, Uint32,
                    Pointer<Pointer<Void>>)>>('m3_GetResults')
        .asFunction();

final int Function(Pointer<Void> func) m3GetArgCount = wasm3Lib
    .lookup<NativeFunction<Uint32 Function(Pointer<Void>)>>('m3_GetArgCount')
    .asFunction();

final int Function(Pointer<Void> func) m3GetRetCount = wasm3Lib
    .lookup<NativeFunction<Uint32 Function(Pointer<Void>)>>('m3_GetRetCount')
    .asFunction();

final int Function(Pointer<Void> func, int index) m3GetArgType = wasm3Lib
    .lookup<NativeFunction<Uint32 Function(Pointer<Void>, Uint32)>>(
        'm3_GetArgType')
    .asFunction();

final int Function(Pointer<Void> func, int index) m3GetRetType = wasm3Lib
    .lookup<NativeFunction<Uint32 Function(Pointer<Void>, Uint32)>>(
        'm3_GetRetType')
    .asFunction();

final Pointer<Uint8> Function(
        Pointer<Void> runtime, Pointer<Uint32> size, int index) m3GetMemory =
    wasm3Lib
        .lookup<
            NativeFunction<
                Pointer<Uint8> Function(Pointer<Void>, Pointer<Uint32>,
                    Uint32 index)>>("m3_GetMemory")
        .asFunction();
