import 'dart:convert';

import 'package:flutter_wasm/flutter_wasm.dart';

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

MoObj toObj(List<int> list) {
  return MoObj(MoTag.getByValue(toUint32(list[0], list[1], list[2], list[3])));
}

MoBlob toBlob(List<int> list) {
  return MoBlob(MoTag.getByValue(toUint32(list[0], list[1], list[2], list[3])),
      toUint32(list[4], list[5], list[6], list[7]));
}

MoConcat toConcat(List<int> list) {
  return MoConcat(
    MoTag.getByValue(toUint32(list[0], list[1], list[2], list[3])),
    toUint32(list[4], list[5], list[6], list[7]),
    toUint32(list[8], list[9], list[10], list[11]),
    toUint32(list[12], list[13], list[14], list[15]),
  );
}

class MoHelper {
  WasmInstance instance;
  dynamic allocBlob;

  MoHelper(this.instance) : allocBlob = instance.lookupFunction("alloc_blob");

  String textToString(int skewedPtr) {
    var ptr = skewedPtr + 1;
    var arr = instance.memory.view.skip(ptr).toList();
    var obj = toObj(arr);
    switch (obj.tag) {
      case MoTag.blob:
        var blb = toBlob(arr);
        var bytes = arr.skip(8).take(blb.len).toList();
        return const Utf8Decoder().convert(bytes);
      case MoTag.concat:
        var conc = toConcat(arr);
        return textToString(conc.text1) + textToString(conc.text2);
      default:
        return '';
    }
  }

  int stringToText(String s) {
    var encoded = const Utf8Encoder().convert(s);
    var skewedPtr = allocBlob(encoded.lengthInBytes);
    var ptr = skewedPtr + 1;

    for (var i = 0; i < encoded.lengthInBytes; i++) {
      instance.memory.view[ptr + 8 + i] = encoded[i];
    }

    return skewedPtr;
  }
}
