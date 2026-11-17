import 'inside_scoop_platform_interface.dart';
import 'src/messages.g.dart';

class MethodChannelInsideScoop extends InsideScoopPlatform {
  MethodChannelInsideScoop({InsideScoopHostApi? hostApi})
    : _hostApi = hostApi ?? InsideScoopHostApi();

  final InsideScoopHostApi _hostApi;

  @override
  Future<String?> getPlatformVersion() {
    return _hostApi.getPlatformVersion();
  }
}
