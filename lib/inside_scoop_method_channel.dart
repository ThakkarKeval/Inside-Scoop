import 'inside_scoop_platform_interface.dart';
import 'src/core/models/app_info.dart';
import 'src/core/models/device_info.dart';
import 'src/core/models/os_info.dart';
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

  @override
  Future<OsInfo> getOsInfo() async {
    final platformOs = await _hostApi.getOsInfo();
    return OsInfo(
      name: platformOs.name,
      version: platformOs.version,
      buildNumber: platformOs.buildNumber,
      architecture: platformOs.architecture,
      kernelVersion: platformOs.kernelVersion,
    );
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final platformDevice = await _hostApi.getDeviceInfo();
    return DeviceInfo(
      model: platformDevice.model,
      manufacturer: platformDevice.manufacturer,
      brand: platformDevice.brand,
      category: DeviceCategory.fromIndex(platformDevice.categoryIndex),
      isPhysicalDevice: platformDevice.isPhysicalDevice,
      supportedAbis: platformDevice.supportedAbis.whereType<String>().toList(),
    );
  }
}
