import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_method_channel.dart';
import 'package:inside_scoop/inside_scoop_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInsideScoopPlatform
    with MockPlatformInterfaceMixin
    implements InsideScoopPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<AppInfo> getAppInfo() => Future.value(
    const AppInfo(
      appName: 'InsideScoopMock',
      packageName: 'com.mock.inside_scoop',
      version: '1.0.0',
      buildNumber: '1',
    ),
  );

  @override
  Future<OsInfo> getOsInfo() => Future.value(
    const OsInfo(
      name: 'MockOS',
      version: '1.0',
      buildNumber: '100',
      architecture: 'arm64',
    ),
  );

  @override
  Future<DeviceInfo> getDeviceInfo() => Future.value(
    const DeviceInfo(
      model: 'MockDevice',
      manufacturer: 'MockMaker',
      brand: 'MockBrand',
      category: DeviceCategory.phone,
      isPhysicalDevice: true,
      supportedAbis: ['arm64'],
    ),
  );

  @override
  Future<CpuInfo> getCpuInfo() => Future.value(
    const CpuInfo(
      architecture: 'arm64',
      modelName: 'MockChip',
      physicalCores: 8,
      logicalCores: 8,
      maxClockSpeedMhz: 3200,
    ),
  );

  @override
  Future<MemoryInfo> getMemoryInfo() => Future.value(
    const MemoryInfo(
      totalPhysicalBytes: 8589934592,
      availablePhysicalBytes: 4294967296,
      isLowMemory: false,
    ),
  );

  @override
  Future<StorageInfo> getStorageInfo() => Future.value(
    const StorageInfo(
      totalBytes: 137438953472, // 128 GB
      availableBytes: 68719476736, // 64 GB
      isRemovable: false,
    ),
  );

  @override
  Future<GpuInfo> getGpuInfo() => Future.value(
    const GpuInfo(
      vendor: 'MockVendor',
      renderer: 'MockGPU',
      apiFamily: 'Metal',
      apiVersion: 'Metal 3',
      totalVramBytes: 8589934592,
      isUnifiedMemory: true,
    ),
  );

  @override
  Future<BatteryInfo> getBatteryInfo() => Future.value(
    const BatteryInfo(
      batteryLevel: 92,
      batteryState: BatteryState.charging,
      powerSource: PowerSource.ac,
      isLowPowerMode: false,
      temperatureCelsius: 29.0,
    ),
  );

  @override
  Future<NetworkInfo> getNetworkInfo() => Future.value(
    const NetworkInfo(
      status: NetworkStatus.connected,
      primaryType: NetworkConnectionType.wifi,
      availableTypes: [NetworkConnectionType.wifi],
      isMetered: false,
      isVpnActive: false,
    ),
  );

  @override
  Stream<NetworkInfo> watchNetworkInfo() => Stream.value(
    const NetworkInfo(
      status: NetworkStatus.connected,
      primaryType: NetworkConnectionType.wifi,
      availableTypes: [NetworkConnectionType.wifi],
      isMetered: false,
      isVpnActive: false,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final InsideScoopPlatform initialPlatform = InsideScoopPlatform.instance;

  test('$MethodChannelInsideScoop is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInsideScoop>());
  });

  test('getPlatformVersion', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    expect(await insideScoopPlugin.getPlatformVersion(), '42');
  });

  test('app.info returns AppInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.app.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.appName, equals('InsideScoopMock'));
  });

  test('os.info returns OsInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.os.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.name, equals('MockOS'));
    expect(result.valueOrNull?.architecture, equals('arm64'));
  });

  test('device.info returns DeviceInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.device.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.model, equals('MockDevice'));
    expect(result.valueOrNull?.category, equals(DeviceCategory.phone));
  });

  test('cpu.info returns CpuInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.cpu.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.architecture, equals('arm64'));
    expect(result.valueOrNull?.modelName, equals('MockChip'));
    expect(result.valueOrNull?.logicalCores, equals(8));
  });

  test('memory.info returns MemoryInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.memory.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.totalPhysicalBytes, equals(8589934592));
    expect(result.valueOrNull?.availablePhysicalBytes, equals(4294967296));
    expect(result.valueOrNull?.isLowMemory, isFalse);
  });

  test('storage.info returns StorageInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.storage.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.totalBytes, equals(137438953472));
    expect(result.valueOrNull?.availableBytes, equals(68719476736));
    expect(result.valueOrNull?.isRemovable, isFalse);
  });

  test('gpu.info returns GpuInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.gpu.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.vendor, equals('MockVendor'));
    expect(result.valueOrNull?.renderer, equals('MockGPU'));
    expect(result.valueOrNull?.apiFamily, equals('Metal'));
    expect(result.valueOrNull?.isUnifiedMemory, isTrue);
  });

  test('battery.info returns BatteryInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.battery.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.batteryLevel, equals(92));
    expect(result.valueOrNull?.batteryState, equals(BatteryState.charging));
    expect(result.valueOrNull?.powerSource, equals(PowerSource.ac));
    expect(result.valueOrNull?.isLowPowerMode, isFalse);
    expect(result.valueOrNull?.temperatureCelsius, equals(29.0));
  });

  test('network.info returns NetworkInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.network.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.status, equals(NetworkStatus.connected));
    expect(result.valueOrNull?.primaryType, equals(NetworkConnectionType.wifi));
    expect(result.valueOrNull?.isConnected, isTrue);
  });

  test('network.watch emits live NetworkInfo updates', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final stream = insideScoopPlugin.network.watch();
    final event = await stream.first;
    expect(event.isConnected, isTrue);
    expect(event.primaryType, equals(NetworkConnectionType.wifi));
  });

  test('monitoring.snapshot combines multi-domain metrics', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final snapshot = await insideScoopPlugin.monitoring.snapshot();
    expect(snapshot.cpu, isNotNull);
    expect(snapshot.memory, isNotNull);
    expect(snapshot.battery, isNotNull);
    expect(snapshot.network, isNotNull);
  });

  test('diagnostics.generateReport produces consolidated report with Markdown export', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final report = await insideScoopPlugin.diagnostics.generateReport();
    expect(report.app?.appName, equals('InsideScoopMock'));
    expect(report.os?.name, equals('MockOS'));
    expect(report.device?.model, equals('MockDevice'));
    expect(report.cpu?.logicalCores, equals(8));
    expect(report.memory?.isLowMemory, isFalse);
    expect(report.storage?.totalBytes, equals(137438953472));
    expect(report.gpu?.vendor, equals('MockVendor'));
    expect(report.battery?.batteryLevel, equals(92));
    expect(report.network?.isConnected, isTrue);

    final md = report.toMarkdown();
    expect(md, contains('# System Diagnostic Report'));
    expect(md, contains('InsideScoopMock'));
  });
}
