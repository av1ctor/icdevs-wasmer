import 'dart:ffi';
// ignore: depend_on_referenced_packages
import 'package:ffi/ffi.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:wasm3/wasm3.dart';

class DataWithLength<T> {
  T data;
  int length;
  DataWithLength(this.data, this.length);
}

enum MoTag {
  blob(17),
  concat(25);

  const MoTag(this.value);
  final int value;
  static MoTag getByValue(num i) {
    return MoTag.values.firstWhere((x) => x.value == i);
  }
}

class MoObj {
  MoTag tag;
  MoObj(this.tag);
}

class MoBlob {
  MoTag tag;
  int len;
  MoBlob(this.tag, this.len);
}

class MoConcat {
  MoTag tag;
  int bytes;
  int text1;
  int text2;
  MoConcat(this.tag, this.bytes, this.text1, this.text2);
}

int toUint32(int a, int b, int c, int d) {
  return a | b << 8 | c << 16 | d << 24;
}

MoObj toObj(Pointer<Uint8> ptr) {
  return MoObj(MoTag.getByValue(toUint32(ptr[0], ptr[1], ptr[2], ptr[3])));
}

MoBlob toBlob(Pointer<Uint8> ptr) {
  return MoBlob(MoTag.getByValue(toUint32(ptr[0], ptr[1], ptr[2], ptr[3])),
      toUint32(ptr[4], ptr[5], ptr[6], ptr[7]));
}

MoConcat toConcat(Pointer<Uint8> ptr) {
  return MoConcat(
    MoTag.getByValue(toUint32(ptr[0], ptr[1], ptr[2], ptr[3])),
    toUint32(ptr[4], ptr[5], ptr[6], ptr[7]),
    toUint32(ptr[8], ptr[9], ptr[10], ptr[11]),
    toUint32(ptr[12], ptr[13], ptr[14], ptr[15]),
  );
}

class MoHelper {
  late Pointer<Void> runtime;
  late Pointer<Void> module;
  late Pointer<Void> allocBlob;

  MoHelper(ByteData wasm) {
    final env = m3NewEnvironment();
    runtime = m3NewRuntime(env, 32768, nullptr);
    if (runtime == nullptr) {
      throw Exception("Could not create the runtime");
    }

    module = _loadModule(wasm, env, runtime);

    final func = calloc<Pointer<Void>>();
    if (m3FindFunction(func, runtime, "alloc_blob".toNativeUtf8()) > 0) {
      throw Exception("Function alloc_blob() not found");
    }
    allocBlob = func.value;
    if (allocBlob == nullptr) {
      throw Exception("Function alloc_blob() not found");
    }
  }

  DataWithLength<Pointer<Uint8>> _toNativeBuffer(ByteData data) {
    final dst = calloc.allocate<Uint8>(data.buffer.lengthInBytes);
    final src = data.buffer.asUint8List();
    for (var i = 0; i < data.lengthInBytes; i++) {
      dst[i] = src[i];
    }
    return DataWithLength(dst, data.lengthInBytes);
  }

  String _toString(Pointer<Uint8> src, int length) {
    final bytes = <int>[];
    for (var i = 0; i < length; i++) {
      bytes.add(src[i]);
    }
    return const Utf8Decoder().convert(bytes);
  }

  Pointer<Void> _loadModule(
      ByteData data, Pointer<Void> env, Pointer<void> runtime) {
    final mod = calloc<Pointer<Void>>();
    final wasm = _toNativeBuffer(data);
    if (m3ParseModule(env, mod, wasm.data, wasm.length) > 0) {
      throw Exception("Could not parse module");
    }

    final module = mod.value;
    if (module == nullptr) {
      throw Exception("Could not parse module");
    }

    m3LinkWASI(mod.value);

    if (m3LoadModule(runtime as Pointer<Void>, mod.value) > 0) {
      throw Exception("Could not load module");
    }

    m3RunStart(mod.value);

    return module;
  }

  Pointer<Void> lookupFunction(String name) {
    final func = calloc<Pointer<Void>>();
    if (m3FindFunction(func, runtime, name.toNativeUtf8()) > 0) {
      throw Exception("Function $name not found");
    }
    return func.value;
  }

  dynamic callFunction(Pointer<Void> func, List<dynamic> args) {
    final valbuff = calloc<Uint64>(args.length * sizeOf<Uint64>());
    final valptrs =
        calloc<Pointer<Void>>(args.length * sizeOf<Pointer<Void>>());

    for (var i = 0; i < args.length; i++) {
      final ptr = valbuff.elementAt(i);

      final arg = args[i];
      switch (arg.runtimeType) {
        case Int32:
          var p32 = ptr as Pointer<Int32>;
          p32.value = arg;
          break;
        case Int64:
        case int:
          var p64 = ptr as Pointer<Int64>;
          p64.value = arg;
          break;
        case Float:
          var f32 = ptr as Pointer<Float>;
          f32.value = arg;
          break;
        case Double:
          var f64 = ptr as Pointer<Double>;
          f64.value = arg;
          break;
        default:
          throw Exception("Invalid argument type");
      }

      valptrs[i] = ptr as Pointer<Void>;
    }

    if (m3Call(func, args.length, valptrs) > 0) {
      throw Exception('Error calling function');
    }

    var retcount = m3GetRetCount(func);
    for (var i = 0; i < retcount; i++) {
      final ptr = valbuff.elementAt(i);
      valptrs[i] = ptr as Pointer<Void>;
    }

    if (retcount == 0) {
      return;
    }

    if (m3GetResults(func, retcount, valptrs) > 0) {
      throw Exception('Error getting function results');
    }

    switch (M3ValueType.getByValue(m3GetArgType(func, 0))) {
      case M3ValueType.none:
        return;
      case M3ValueType.i32:
        var p32 = valptrs[0] as Pointer<Int32>;
        return p32.value;
      case M3ValueType.i64:
        var p64 = valptrs[0] as Pointer<Int64>;
        return p64.value;
      case M3ValueType.f32:
        var f32 = valptrs[0] as Pointer<Float>;
        return f32.value;
      case M3ValueType.f64:
        var f64 = valptrs[0] as Pointer<Double>;
        return f64.value;
      case M3ValueType.unknown:
        throw Exception("Unknown return type");
    }
  }

  Pointer<Uint8> getMemory() {
    return m3GetMemory(runtime, nullptr, 0);
  }

  String textToString(int skewedPtr) {
    var ptr = skewedPtr + 1;
    var arr = getMemory().elementAt(ptr);
    if (arr != nullptr) {
      var obj = toObj(arr);
      switch (obj.tag) {
        case MoTag.blob:
          var blb = toBlob(arr);
          var bytes = arr.elementAt(8);
          return _toString(bytes, blb.len);
        case MoTag.concat:
          var conc = toConcat(arr);
          return textToString(conc.text1) + textToString(conc.text2);
        default:
          return '';
      }
    } else {
      return '';
    }
  }

  int stringToText(String s) {
    var encoded = const Utf8Encoder().convert(s);
    var skewedPtr = callFunction(allocBlob, [encoded.lengthInBytes]);
    var ptr = skewedPtr + 1;

    var arr = getMemory().elementAt(ptr + 8);
    for (var i = 0; i < encoded.lengthInBytes; i++) {
      arr[i] = encoded[i];
    }

    return skewedPtr;
  }
}
