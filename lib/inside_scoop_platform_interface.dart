import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inside_scoop_method_channel.dart';
import 'src/core/models/app_info.dart';
import 'src/core/models/battery_info.dart';
import 'src/core/models/cpu_info.dart';
import 'src/core/models/device_info.dart';
import 'src/core/models/gpu_info.dart';
import 'src/core/models/memory_info.dart';
import 'src/core/models/os_info.dart';
import 'src/core/models/storage_info.dart';

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

  Future<AppInfo> getAppInfo() {
    throw UnimplementedError('getAppInfo() has not been implemented.');
  }

  Future<OsInfo> getOsInfo() {
    throw UnimplementedError('getOsInfo() has not been implemented.');
  }

  Future<DeviceInfo> getDeviceInfo() {
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }

  Future<CpuInfo> getCpuInfo() {
    throw UnimplementedError('getCpuInfo() has not been implemented.');
  }

  Future<MemoryInfo> getMemoryInfo() {
    throw UnimplementedError('getMemoryInfo() has not been implemented.');
  }

  Future<StorageInfo> getStorageInfo() {
    throw UnimplementedError('getStorageInfo() has not been implemented.');
  }

  Future<GpuInfo> getGpuInfo() {
    throw UnimplementedError('getGpuInfo() has not been implemented.');
  }

  Future<BatteryInfo> getBatteryInfo() {
    throw UnimplementedError('getBatteryInfo() has not been implemented.');
  }
}
