// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

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
    final metaVersion = web.document.querySelector('meta[name="version"]')?.getAttribute('content') ??
        web.document.querySelector('meta[name="app-version"]')?.getAttribute('content');
    final metaBuild = web.document.querySelector('meta[name="build-number"]')?.getAttribute('content');

    return AppInfo(
      appName: title.isNotEmpty ? title : 'Web Application',
      packageName: host.isNotEmpty ? host : 'unknown',
      version: metaVersion ?? 'unknown',
      buildNumber: metaBuild ?? 'unknown',
      installerStore: host.isNotEmpty ? host : null,
    );
  }

  @override
  Future<OsInfo> getOsInfo() async {
    final ua = web.window.navigator.userAgent;
    final platform = web.window.navigator.platform;
    return OsInfo(
      name: platform.isNotEmpty ? 'Web ($platform)' : 'Web',
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
    final ua = web.window.navigator.userAgent.toLowerCase();
    final isHeadless = ua.contains('headless') || ua.contains('puppeteer') || ua.contains('playwright');

    return DeviceInfo(
      model: 'Browser Client',
      manufacturer: 'Web Client',
      brand: 'Web',
      category: category,
      isPhysicalDevice: !isHeadless,
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
    int totalBytes = 0;
    try {
      final mem = web.window.navigator.deviceMemory;
      if (mem > 0) {
        totalBytes = (mem * 1024 * 1024 * 1024).round();
      }
    } catch (_) {}

    return MemoryInfo(
      totalPhysicalBytes: totalBytes,
      availablePhysicalBytes: 0,
      processResidentBytes: null,
      processVirtualBytes: null,
      isLowMemory: false,
    );
  }

  @override
  Future<StorageInfo> getStorageInfo() async {
    int total = 0;
    int available = 0;

    try {
      final storageManager = web.window.navigator.storage;
      final estimatePromise = storageManager.estimate();
      final estimate = await estimatePromise.toDart;
      final quota = estimate.quota;
      final usage = estimate.usage;
      if (quota > 0) {
        total = quota;
        available = (quota - usage) > 0 ? (quota - usage) : 0;
      }
    } catch (_) {}

    return StorageInfo(
      totalBytes: total,
      availableBytes: available,
      appStorageBytes: null,
      isRemovable: false,
    );
  }

  @override
  Future<GpuInfo> getGpuInfo() async {
    String vendor = 'unknown';
    String renderer = 'unknown';
    String? apiVersion;

    try {
      final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
      final gl = (canvas.getContext('webgl2') ?? canvas.getContext('webgl')) as web.WebGLRenderingContext?;
      if (gl != null) {
        apiVersion = (gl is web.WebGL2RenderingContext) ? 'WebGL 2.0' : 'WebGL 1.0';
        final debugInfo = gl.getExtension('WEBGL_debug_renderer_info');
        if (debugInfo != null) {
          final unmaskedVendor = gl.getParameter(0x9245);
          final unmaskedRenderer = gl.getParameter(0x9246);
          if (unmaskedVendor != null) vendor = unmaskedVendor.toString();
          if (unmaskedRenderer != null) renderer = unmaskedRenderer.toString();
        } else {
          final v = gl.getParameter(0x1F00);
          final r = gl.getParameter(0x1F01);
          if (v != null) vendor = v.toString();
          if (r != null) renderer = r.toString();
        }
      }
    } catch (_) {}

    return GpuInfo(
      vendor: vendor,
      renderer: renderer,
      apiFamily: apiVersion != null ? 'WebGL' : null,
      apiVersion: apiVersion,
      totalVramBytes: null,
      isUnifiedMemory: null,
    );
  }

  @override
  Future<BatteryInfo> getBatteryInfo() async {
    return const BatteryInfo(
      batteryLevel: null,
      batteryState: BatteryState.unknown,
      powerSource: PowerSource.unknown,
      isLowPowerMode: null,
      temperatureCelsius: null,
      chargeWatts: null,
    );
  }

  @override
  Future<NetworkInfo> getNetworkInfo() async {
    final isOnline = web.window.navigator.onLine;
    return NetworkInfo(
      status: isOnline ? NetworkStatus.connected : NetworkStatus.disconnected,
      primaryType: isOnline ? NetworkConnectionType.other : NetworkConnectionType.none,
      availableTypes: isOnline ? [NetworkConnectionType.other] : [],
      isMetered: null,
      isVpnActive: null,
    );
  }

  @override
  Stream<NetworkInfo> watchNetworkInfo() {
    late final StreamController<NetworkInfo> controller;
    void emitCurrent() {
      if (!controller.isClosed) {
        final isOnline = web.window.navigator.onLine;
        controller.add(
          NetworkInfo(
            status: isOnline ? NetworkStatus.connected : NetworkStatus.disconnected,
            primaryType: isOnline ? NetworkConnectionType.other : NetworkConnectionType.none,
            availableTypes: isOnline ? [NetworkConnectionType.other] : [],
          ),
        );
      }
    }

    controller = StreamController<NetworkInfo>.broadcast(
      onListen: () {
        emitCurrent();
        web.window.addEventListener('online', ((web.Event _) { emitCurrent(); }).toJS);
        web.window.addEventListener('offline', ((web.Event _) { emitCurrent(); }).toJS);
      },
    );

    return controller.stream;
  }
}
