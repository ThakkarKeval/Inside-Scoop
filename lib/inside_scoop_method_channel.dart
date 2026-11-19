import 'package:flutter/services.dart';

import 'inside_scoop_platform_interface.dart';
import 'src/core/models/app_info.dart';
import 'src/core/models/battery_info.dart';
import 'src/core/models/cpu_info.dart';
import 'src/core/models/device_info.dart';
import 'src/core/models/gpu_info.dart';
import 'src/core/models/memory_info.dart';
import 'src/core/models/network_info.dart';
import 'src/core/models/os_info.dart';
import 'src/core/models/storage_info.dart';
import 'src/messages.g.dart';

class MethodChannelInsideScoop extends InsideScoopPlatform {
  MethodChannelInsideScoop({
    InsideScoopHostApi? hostApi,
    EventChannel? networkEventChannel,
  })  : _hostApi = hostApi ?? InsideScoopHostApi(),
        _networkEventChannel = networkEventChannel ??
            const EventChannel('com.cavernlabs.inside_scoop/network_events');

  final InsideScoopHostApi _hostApi;
  final EventChannel _networkEventChannel;

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

  @override
  Future<CpuInfo> getCpuInfo() async {
    final platformCpu = await _hostApi.getCpuInfo();
    return CpuInfo(
      architecture: platformCpu.architecture,
      modelName: platformCpu.modelName,
      physicalCores: platformCpu.physicalCores,
      logicalCores: platformCpu.logicalCores,
      maxClockSpeedMhz: platformCpu.maxClockSpeedMhz,
      systemUtilization: platformCpu.systemUtilization,
      processUtilization: platformCpu.processUtilization,
    );
  }

  @override
  Future<MemoryInfo> getMemoryInfo() async {
    final platformMemory = await _hostApi.getMemoryInfo();
    return MemoryInfo(
      totalPhysicalBytes: platformMemory.totalPhysicalBytes,
      availablePhysicalBytes: platformMemory.availablePhysicalBytes,
      processResidentBytes: platformMemory.processResidentBytes,
      processVirtualBytes: platformMemory.processVirtualBytes,
      isLowMemory: platformMemory.isLowMemory,
      totalPssBytes: platformMemory.totalPssBytes,
      jvmHeapAllocatedBytes: platformMemory.jvmHeapAllocatedBytes,
      jvmHeapUsedBytes: platformMemory.jvmHeapUsedBytes,
    );
  }

  @override
  Future<StorageInfo> getStorageInfo() async {
    final platformStorage = await _hostApi.getStorageInfo();
    return StorageInfo(
      totalBytes: platformStorage.totalBytes,
      availableBytes: platformStorage.availableBytes,
      appStorageBytes: platformStorage.appStorageBytes,
      isRemovable: platformStorage.isRemovable,
    );
  }

  @override
  Future<GpuInfo> getGpuInfo() async {
    final platformGpu = await _hostApi.getGpuInfo();
    return GpuInfo(
      vendor: platformGpu.vendor,
      renderer: platformGpu.renderer,
      apiFamily: platformGpu.apiFamily,
      apiVersion: platformGpu.apiVersion,
      totalVramBytes: platformGpu.totalVramBytes,
      isUnifiedMemory: platformGpu.isUnifiedMemory,
    );
  }

  @override
  Future<BatteryInfo> getBatteryInfo() async {
    final platformBattery = await _hostApi.getBatteryInfo();
    return BatteryInfo(
      batteryLevel: platformBattery.batteryLevel,
      batteryState: BatteryState.fromIndex(platformBattery.batteryStateIndex),
      powerSource: PowerSource.fromIndex(platformBattery.powerSourceIndex),
      isLowPowerMode: platformBattery.isLowPowerMode,
      temperatureCelsius: platformBattery.temperatureCelsius,
      chargeWatts: platformBattery.chargeWatts,
    );
  }

  @override
  Future<NetworkInfo> getNetworkInfo() async {
    final platformNet = await _hostApi.getNetworkInfo();
    return NetworkInfo(
      status: NetworkStatus.fromIndex(platformNet.statusIndex),
      primaryType: NetworkConnectionType.fromIndex(platformNet.primaryTypeIndex),
      availableTypes: platformNet.availableTypeIndices
          .whereType<int>()
          .map(NetworkConnectionType.fromIndex)
          .toList(),
      isMetered: platformNet.isMetered,
      isVpnActive: platformNet.isVpnActive,
    );
  }

  @override
  Stream<NetworkInfo> watchNetworkInfo() {
    return _networkEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          if (event is Map) {
            return NetworkInfo.fromMap(Map<String, dynamic>.from(event));
          }
          return const NetworkInfo(
            status: NetworkStatus.unknown,
            primaryType: NetworkConnectionType.none,
          );
        });
  }
}
