import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wasm3_method_channel.dart';

abstract class Wasm3Platform extends PlatformInterface {
  /// Constructs a Wasm3Platform.
  Wasm3Platform() : super(token: _token);

  static final Object _token = Object();

  static Wasm3Platform _instance = MethodChannelWasm3();

  /// The default instance of [Wasm3Platform] to use.
  ///
  /// Defaults to [MethodChannelWasm3].
  static Wasm3Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Wasm3Platform] when
  /// they register themselves.
  static set instance(Wasm3Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
