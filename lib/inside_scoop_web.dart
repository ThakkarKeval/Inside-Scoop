// ignore: avoid_web_libraries_in_flutter
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'inside_scoop_platform_interface.dart';
import 'src/core/models/app_info.dart';
import 'src/core/models/cpu_info.dart';
import 'src/core/models/device_info.dart';
import 'src/core/models/gpu_info.dart';
import 'src/core/models/memory_info.dart';
import 'src/core/models/os_info.dart';
import 'src/core/models/storage_info.dart';

class InsideScoopWeb extends InsideScoopPlatform {
  InsideScoopWeb();

  static void registerWith(Registrar registrar) {
    InsideScoopPlatform.instance = InsideScoopWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return web.window.navigator.userAgent;
  }

  @override
  Future<AppInfo> getAppInfo() async {
    final title = web.document.title;
    final host = web.window.location.host;
    return AppInfo(
      appName: title.isNotEmpty ? title : 'Web Application',
      packageName: host.isNotEmpty ? host : 'web.local',
      version: '1.0.0',
      buildNumber: '1',
      installerStore: 'web',
    );
  }

  @override
  Future<OsInfo> getOsInfo() async {
    final ua = web.window.navigator.userAgent;
    final platform = web.window.navigator.platform;
    return OsInfo(
      name: 'Web ($platform)',
      version: 'Browser',
      buildNumber: ua,
      architecture: 'wasm/js',
      kernelVersion: null,
    );
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final touchPoints = web.window.navigator.maxTouchPoints;
    final width = web.window.screen.width;
    final category = touchPoints > 0
        ? (width < 600 ? DeviceCategory.phone : DeviceCategory.tablet)
        : DeviceCategory.desktop;

    return DeviceInfo(
      model: 'Browser Client',
      manufacturer: 'Web Client',
      brand: 'Web',
      category: category,
      isPhysicalDevice: true,
      supportedAbis: const <String>['wasm', 'javascript'],
    );
  }

  @override
  Future<CpuInfo> getCpuInfo() async {
    final concurrency = web.window.navigator.hardwareConcurrency;
    final ua = web.window.navigator.userAgent.toLowerCase();
    String arch = 'unknown';
    if (ua.contains('arm64') || ua.contains('aarch64')) {
      arch = 'arm64';
    } else if (ua.contains('x86_64') ||
        ua.contains('win64') ||
        ua.contains('x64') ||
        ua.contains('amd64')) {
      arch = 'x86_64';
    }

    return CpuInfo(
      architecture: arch,
      modelName: null,
      physicalCores: null,
      logicalCores: concurrency > 0 ? concurrency : 1,
      maxClockSpeedMhz: null,
      systemUtilization: null,
      processUtilization: null,
    );
  }

  @override
  Future<MemoryInfo> getMemoryInfo() async {
    int totalBytes = 4 * 1024 * 1024 * 1024;
    try {
      final mem = web.window.navigator.deviceMemory;
      if (mem > 0) {
        totalBytes = (mem * 1024 * 1024 * 1024).round();
      }
    } catch (_) {}

    return MemoryInfo(
      totalPhysicalBytes: totalBytes,
      availablePhysicalBytes: (totalBytes * 0.5).round(),
      processResidentBytes: null,
      processVirtualBytes: null,
      isLowMemory: false,
    );
  }

  @override
  Future<StorageInfo> getStorageInfo() async {
    int total = 10 * 1024 * 1024 * 1024;
    int available = 8 * 1024 * 1024 * 1024;

    return StorageInfo(
      totalBytes: total,
      availableBytes: available,
      appStorageBytes: null,
      isRemovable: false,
    );
  }

  @override
  Future<GpuInfo> getGpuInfo() async {
    return const GpuInfo(
      vendor: 'Web Browser',
      renderer: 'WebGL Context',
      apiFamily: 'WebGL',
      apiVersion: '2.0',
      totalVramBytes: null,
      isUnifiedMemory: null,
    );
  }
}
