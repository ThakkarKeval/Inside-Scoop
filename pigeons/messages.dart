import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/src/main/kotlin/com/cavernlabs/inside/scoop/inside_scoop/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.cavernlabs.inside.scoop.inside_scoop',
    ),
    swiftOut: [
      'ios/inside_scoop/Sources/inside_scoop/Messages.g.swift',
      'macos/inside_scoop/Sources/inside_scoop/Messages.g.swift',
    ],
    swiftOptions: SwiftOptions(),
    cppHeaderOut: 'windows/messages.g.h',
    cppSourceOut: 'windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'inside_scoop'),
  ),
)
class PlatformAppInfo {
  PlatformAppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.buildSignature,
    this.installerStore,
  });

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String? buildSignature;
  final String? installerStore;
}

class PlatformOsInfo {
  PlatformOsInfo({
    required this.name,
    required this.version,
    required this.buildNumber,
    required this.architecture,
    this.kernelVersion,
  });

  final String name;
  final String version;
  final String buildNumber;
  final String architecture;
  final String? kernelVersion;
}

class PlatformDeviceInfo {
  PlatformDeviceInfo({
    required this.model,
    required this.manufacturer,
    required this.brand,
    required this.categoryIndex,
    required this.isPhysicalDevice,
    required this.supportedAbis,
  });

  final String model;
  final String manufacturer;
  final String brand;
  final int categoryIndex;
  final bool isPhysicalDevice;
  final List<String?> supportedAbis;
}

class PlatformCpuInfo {
  PlatformCpuInfo({
    required this.architecture,
    this.modelName,
    this.physicalCores,
    required this.logicalCores,
    this.maxClockSpeedMhz,
    this.systemUtilization,
    this.processUtilization,
  });

  final String architecture;
  final String? modelName;
  final int? physicalCores;
  final int logicalCores;
  final int? maxClockSpeedMhz;
  final double? systemUtilization;
  final double? processUtilization;
}

class PlatformMemoryInfo {
  PlatformMemoryInfo({
    required this.totalPhysicalBytes,
    required this.availablePhysicalBytes,
    this.processResidentBytes,
    this.processVirtualBytes,
    required this.isLowMemory,
  });

  final int totalPhysicalBytes;
  final int availablePhysicalBytes;
  final int? processResidentBytes;
  final int? processVirtualBytes;
  final bool isLowMemory;
}

class PlatformStorageInfo {
  PlatformStorageInfo({
    required this.totalBytes,
    required this.availableBytes,
    this.appStorageBytes,
    required this.isRemovable,
  });

  final int totalBytes;
  final int availableBytes;
  final int? appStorageBytes;
  final bool isRemovable;
}

class PlatformGpuInfo {
  PlatformGpuInfo({
    required this.vendor,
    required this.renderer,
    this.apiFamily,
    this.apiVersion,
    this.totalVramBytes,
    this.isUnifiedMemory,
  });

  final String vendor;
  final String renderer;
  final String? apiFamily;
  final String? apiVersion;
  final int? totalVramBytes;
  final bool? isUnifiedMemory;
}

@HostApi()
abstract class InsideScoopHostApi {
  String? getPlatformVersion();
  PlatformAppInfo getAppInfo();
  PlatformOsInfo getOsInfo();
  PlatformDeviceInfo getDeviceInfo();
  PlatformCpuInfo getCpuInfo();
  PlatformMemoryInfo getMemoryInfo();
  PlatformStorageInfo getStorageInfo();
  PlatformGpuInfo getGpuInfo();
}
