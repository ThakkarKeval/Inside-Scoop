import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('MonitoringConfig', () {
    test('default configuration has expected cadences and flags', () {
      const config = MonitoringConfig();
      expect(config.interval, equals(const Duration(seconds: 1)));
      expect(config.sampleCpu, isTrue);
      expect(config.sampleMemory, isTrue);
      expect(config.sampleBattery, isTrue);
      expect(config.sampleNetwork, isTrue);
      expect(config.pauseInBackground, isTrue);
    });

    test('equality and hashcode match identical configurations', () {
      const c1 = MonitoringConfig(interval: Duration(seconds: 2));
      const c2 = MonitoringConfig(interval: Duration(seconds: 2));
      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
    });
  });

  group('SystemMetricsSnapshot', () {
    final now = DateTime.now();
    final sampleSnapshot = SystemMetricsSnapshot(
      timestamp: now,
      cpu: const CpuInfo(
        architecture: 'arm64',
        logicalCores: 8,
      ),
      memory: const MemoryInfo(
        totalPhysicalBytes: 16 * 1024 * 1024 * 1024,
        availablePhysicalBytes: 8 * 1024 * 1024 * 1024,
        isLowMemory: false,
      ),
      battery: const BatteryInfo(
        batteryLevel: 80,
        batteryState: BatteryState.discharging,
        powerSource: PowerSource.battery,
      ),
      network: const NetworkInfo(
        status: NetworkStatus.connected,
        primaryType: NetworkConnectionType.wifi,
      ),
    );

    test('serializes to and from Map accurately', () {
      final map = sampleSnapshot.toMap();
      expect(map['timestamp'], equals(now.toIso8601String()));
      expect(map['cpu'], isNotNull);
      expect(map['memory'], isNotNull);
      expect(map['battery'], isNotNull);
      expect(map['network'], isNotNull);

      final restored = SystemMetricsSnapshot.fromMap(map);
      expect(restored.cpu?.architecture, equals('arm64'));
      expect(restored.memory?.totalPhysicalBytes, equals(16 * 1024 * 1024 * 1024));
      expect(restored.battery?.batteryLevel, equals(80));
      expect(restored.network?.primaryType, equals(NetworkConnectionType.wifi));
    });

    test('copyWith creates modified snapshot correctly', () {
      const newBattery = BatteryInfo(
        batteryLevel: 79,
        batteryState: BatteryState.discharging,
        powerSource: PowerSource.battery,
      );

      final modified = sampleSnapshot.copyWith(battery: newBattery);
      expect(modified.battery?.batteryLevel, equals(79));
      expect(modified.cpu, equals(sampleSnapshot.cpu));
    });

    test('toString includes formatted description', () {
      final str = sampleSnapshot.toString();
      expect(str, contains('CPU: true'));
      expect(str, contains('Memory: true'));
      expect(str, contains('Battery: true'));
      expect(str, contains('Network: true'));
    });
  });
}
