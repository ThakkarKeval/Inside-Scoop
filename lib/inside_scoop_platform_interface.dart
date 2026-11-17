import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inside_scoop_method_channel.dart';

abstract class InsideScoopPlatform extends PlatformInterface {
  InsideScoopPlatform() : super(token: _token);

  static final Object _token = Object();

  static InsideScoopPlatform _instance = MethodChannelInsideScoop();

  static InsideScoopPlatform get instance => _instance;

  static set instance(InsideScoopPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
