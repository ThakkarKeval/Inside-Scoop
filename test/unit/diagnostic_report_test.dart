import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('DiagnosticOptions', () {
    test('default options match expected privacy settings', () {
      const options = DiagnosticOptions();
      expect(options.maskSignatures, isTrue);
      expect(options.maskDeviceIdentifiers, isFalse);
      expect(options.includeCapabilities, isTrue);
    });

    test('equality and hashCode match identical options', () {
      const o1 = DiagnosticOptions(maskSignatures: false);
      const o2 = DiagnosticOptions(maskSignatures: false);
      expect(o1, equals(o2));
      expect(o1.hashCode, equals(o2.hashCode));
    });
  });

  group('DiagnosticReport', () {
    final now = DateTime.utc(2026, 11, 18, 10, 0, 0);
    final sampleReport = DiagnosticReport(
      generatedAt: now,
      app: const AppInfo(
        appName: 'InsideScoopDemo',
        packageName: 'com.cavernlabs.demo',
        version: '1.0.0',
        buildNumber: '42',
        buildSignature: 'ABCD1234...[REDACTED]',
        installerStore: 'Google Play',
      ),
      os: const OsInfo(
        name: 'Android',
        version: '14',
        buildNumber: 'UP1A.231005.007',
        architecture: 'arm64',
        kernelVersion: '5.15.0',
      ),
      device: const DeviceInfo(
        model: 'Pixel 8',
        manufacturer: 'Google',
        brand: 'google',
        category: DeviceCategory.phone,
        isPhysicalDevice: true,
        supportedAbis: ['arm64-v8a'],
      ),
      cpu: const CpuInfo(
        architecture: 'arm64',
        modelName: 'Google Tensor G3',
        logicalCores: 9,
      ),
      memory: const MemoryInfo(
        totalPhysicalBytes: 8589934592,
        availablePhysicalBytes: 4294967296,
        isLowMemory: false,
      ),
      storage: const StorageInfo(
        totalBytes: 137438953472,
        availableBytes: 68719476736,
        isRemovable: false,
      ),
      gpu: const GpuInfo(
        vendor: 'ARM',
        renderer: 'Mali-G715',
        apiFamily: 'Vulkan',
        apiVersion: '1.3',
      ),
      battery: const BatteryInfo(
        batteryLevel: 88,
        batteryState: BatteryState.discharging,
        powerSource: PowerSource.battery,
      ),
      network: const NetworkInfo(
        status: NetworkStatus.connected,
        primaryType: NetworkConnectionType.wifi,
      ),
      capabilities: const {
        ScoopFeature.applicationInfo: ScoopCapabilityInfo(
          feature: ScoopFeature.applicationInfo,
          state: ScoopCapabilityState.supported,
          description: 'Fully supported on Android.',
        ),
      },
    );

    test('serializes to and from Map and JSON accurately', () {
      final map = sampleReport.toMap();
      expect(map['generatedAt'], equals(now.toIso8601String()));
      expect(map['app'], isNotNull);
      expect(map['os'], isNotNull);
      expect(map['device'], isNotNull);
      expect(map['cpu'], isNotNull);
      expect(map['capabilities'], isNotNull);

      final jsonStr = sampleReport.toJson(pretty: true);
      expect(jsonStr, contains('InsideScoopDemo'));
      expect(jsonStr, contains('Pixel 8'));

      final restored = DiagnosticReport.fromJson(jsonStr);
      expect(restored.app?.appName, equals('InsideScoopDemo'));
      expect(restored.os?.name, equals('Android'));
      expect(restored.device?.model, equals('Pixel 8'));
      expect(restored.cpu?.modelName, equals('Google Tensor G3'));
      expect(restored.battery?.batteryLevel, equals(88));
      expect(restored.capabilities?[ScoopFeature.applicationInfo]?.state, equals(ScoopCapabilityState.supported));
    });

    test('toMarkdown formats into structured markdown with headings and sections', () {
      final md = sampleReport.toMarkdown();
      expect(md, contains('# System Diagnostic Report'));
      expect(md, contains('## Application Information'));
      expect(md, contains('InsideScoopDemo'));
      expect(md, contains('## Operating System & Hardware'));
      expect(md, contains('Pixel 8'));
      expect(md, contains('## Processing Units'));
      expect(md, contains('Mali-G715'));
      expect(md, contains('## Memory & Storage'));
      expect(md, contains('## Power & Connectivity'));
      expect(md, contains('## Platform Capabilities'));
      expect(md, contains('applicationInfo'));
    });

    test('copyWith creates modified report correctly', () {
      final modified = sampleReport.copyWith(
        app: const AppInfo(
          appName: 'ModifiedApp',
          packageName: 'com.test',
          version: '2.0.0',
          buildNumber: '1',
        ),
      );

      expect(modified.app?.appName, equals('ModifiedApp'));
      expect(modified.os, equals(sampleReport.os));
    });

    test('toString returns concise description', () {
      final str = sampleReport.toString();
      expect(str, contains('DiagnosticReport'));
      expect(str, contains('App: true'));
    });
  });
}
