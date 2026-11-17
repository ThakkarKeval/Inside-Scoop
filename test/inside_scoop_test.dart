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
}
