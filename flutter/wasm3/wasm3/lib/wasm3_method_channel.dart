import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wasm3_platform_interface.dart';

/// An implementation of [Wasm3Platform] that uses method channels.
class MethodChannelWasm3 extends Wasm3Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wasm3');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
