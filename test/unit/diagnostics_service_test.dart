import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_platform_interface.dart';

class FakeDiagnosticPlatform extends InsideScoopPlatform {
  @override
  Future<AppInfo> getAppInfo() => Future.value(
    const AppInfo(
      appName: 'FakeApp',
      packageName: 'com.fake.app',
      version: '1.2.3',
      buildNumber: '10',
      buildSignature: 'A1B2C3D4E5F6G7H8I9J0',
    ),
  );

  @override
  Future<OsInfo> getOsInfo() => Future.value(
    const OsInfo(
      name: 'macOS',
      version: '14.5',
      buildNumber: '23F79',
      architecture: 'arm64',
    ),
  );

  @override
  Future<DeviceInfo> getDeviceInfo() => Future.value(
    const DeviceInfo(
      model: 'MacBookPro18,1',
      manufacturer: 'Apple',
      brand: 'Apple',
      category: DeviceCategory.laptop,
      isPhysicalDevice: true,
      supportedAbis: ['arm64'],
    ),
  );

  @override
  Future<CpuInfo> getCpuInfo() => Future.value(
    const CpuInfo(
      architecture: 'arm64',
      modelName: 'Apple M1 Pro',
      logicalCores: 10,
    ),
  );

  @override
  Future<MemoryInfo> getMemoryInfo() => Future.value(
    const MemoryInfo(
      totalPhysicalBytes: 17179869184,
      availablePhysicalBytes: 8589934592,
      isLowMemory: false,
    ),
  );

  @override
  Future<StorageInfo> getStorageInfo() => Future.value(
    const StorageInfo(
      totalBytes: 512 * 1024 * 1024 * 1024,
      availableBytes: 256 * 1024 * 1024 * 1024,
      isRemovable: false,
    ),
  );

  @override
  Future<GpuInfo> getGpuInfo() => Future.value(
    const GpuInfo(
      vendor: 'Apple',
      renderer: 'Apple M1 Pro',
      apiFamily: 'Metal',
      apiVersion: 'Metal 3',
    ),
  );

  @override
  Future<BatteryInfo> getBatteryInfo() => Future.value(
    const BatteryInfo(
      batteryLevel: 90,
      batteryState: BatteryState.discharging,
      powerSource: PowerSource.battery,
    ),
  );

  @override
  Future<NetworkInfo> getNetworkInfo() => Future.value(
    const NetworkInfo(
      status: NetworkStatus.connected,
      primaryType: NetworkConnectionType.wifi,
    ),
  );
}

void main() {
  group('DiagnosticsService', () {
    late FakeDiagnosticPlatform platform;
    late DiagnosticsService service;

    setUp(() {
      platform = FakeDiagnosticPlatform();
      service = DiagnosticsService(platform);
    });

    test('generateReport aggregates all subsystems and masks signature by default', () async {
      final report = await service.generateReport();

      expect(report.app?.appName, equals('FakeApp'));
      expect(report.app?.buildSignature, equals('A1B2C3D4...[REDACTED]'));
      expect(report.os?.name, equals('macOS'));
      expect(report.device?.model, equals('MacBookPro18,1'));
      expect(report.cpu?.modelName, equals('Apple M1 Pro'));
      expect(report.memory?.totalPhysicalBytes, equals(17179869184));
      expect(report.storage?.totalBytes, equals(512 * 1024 * 1024 * 1024));
      expect(report.gpu?.vendor, equals('Apple'));
      expect(report.battery?.batteryLevel, equals(90));
      expect(report.network?.isConnected, isTrue);
      expect(report.capabilities, isNotNull);
    });

    test('generateReport masks device identifiers when configured', () async {
      const options = DiagnosticOptions(
        maskSignatures: false,
        maskDeviceIdentifiers: true,
        includeCapabilities: false,
      );

      final report = await service.generateReport(options: options);

      expect(report.app?.buildSignature, equals('A1B2C3D4E5F6G7H8I9J0'));
      expect(report.device?.model, equals('[REDACTED_MODEL]'));
      expect(report.device?.brand, equals('[REDACTED_BRAND]'));
      expect(report.capabilities, isNull);
    });
  });
}
