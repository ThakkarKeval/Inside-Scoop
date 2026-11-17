import 'inside_scoop_platform_interface.dart';
import 'src/core/models/app_info.dart';
import 'src/messages.g.dart';

class MethodChannelInsideScoop extends InsideScoopPlatform {
  MethodChannelInsideScoop({InsideScoopHostApi? hostApi})
    : _hostApi = hostApi ?? InsideScoopHostApi();

  final InsideScoopHostApi _hostApi;

  @override
  Future<String?> getPlatformVersion() {
    return _hostApi.getPlatformVersion();
  }

  @override
  Future<AppInfo> getAppInfo() async {
    final platformInfo = await _hostApi.getAppInfo();
    return AppInfo(
      appName: platformInfo.appName,
      packageName: platformInfo.packageName,
      version: platformInfo.version,
      buildNumber: platformInfo.buildNumber,
      buildSignature: platformInfo.buildSignature,
      installerStore: platformInfo.installerStore,
    );
  }
}
