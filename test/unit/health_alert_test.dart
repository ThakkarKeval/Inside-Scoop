import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('HealthThresholds & HealthAlert', () {
    const thresholds = HealthThresholds(
      lowMemoryTrigger: true,
      maxMemoryUsagePercentage: 85.0,
      maxProcessResidentMb: 150.0,
      maxBatteryTemperatureCelsius: 42.0,
      lowBatteryPercent: 20,
      maxCpuUtilizationPercent: 90.0,
    );

    test('triggers critical low memory alert when isLowMemory is true', () {
      final now = DateTime.now();
      final snapshot = SystemMetricsSnapshot(
        timestamp: now,
        memory: const MemoryInfo(
          totalPhysicalBytes: 8 * 1024 * 1024 * 1024,
          availablePhysicalBytes: 1 * 1024 * 1024 * 1024,
          isLowMemory: true,
        ),
      );

      final alerts = thresholds.evaluate(snapshot);
      expect(alerts.any((a) => a.title == 'Critical Low Memory'), isTrue);
      final alert = alerts.firstWhere((a) => a.title == 'Critical Low Memory');
      expect(alert.severity, equals(HealthAlertSeverity.critical));
      expect(alert.category, equals(HealthAlertCategory.memory));
      expect(alert.timestamp, equals(now));

      final map = alert.toMap();
      expect(map['severity'], equals('critical'));
      expect(map['category'], equals('memory'));
    });

    test('triggers high RAM utilization when usage exceeds percentage', () {
      final now = DateTime.now();
      final snapshot = SystemMetricsSnapshot(
        timestamp: now,
        memory: const MemoryInfo(
          totalPhysicalBytes: 10 * 1024 * 1024 * 1024,
          availablePhysicalBytes: 1 * 1024 * 1024 * 1024, // 90% used
          isLowMemory: false,
        ),
      );

      final alerts = thresholds.evaluate(snapshot);
      expect(alerts.any((a) => a.title == 'High RAM Utilization'), isTrue);
      final alert = alerts.firstWhere((a) => a.title == 'High RAM Utilization');
      expect(alert.severity, equals(HealthAlertSeverity.warning));
    });

    test('triggers process memory exceeded when RSS exceeds threshold', () {
      final now = DateTime.now();
      final snapshot = SystemMetricsSnapshot(
        timestamp: now,
        memory: const MemoryInfo(
          totalPhysicalBytes: 8 * 1024 * 1024 * 1024,
          availablePhysicalBytes: 4 * 1024 * 1024 * 1024,
          processResidentBytes: 200 * 1024 * 1024, // 200 MB > 150 MB
          isLowMemory: false,
        ),
      );

      final alerts = thresholds.evaluate(snapshot);
      expect(alerts.any((a) => a.title == 'Process Memory Exceeded'), isTrue);
    });

    test('triggers thermal and low battery alerts', () {
      final now = DateTime.now();
      final snapshot = SystemMetricsSnapshot(
        timestamp: now,
        battery: const BatteryInfo(
          batteryLevel: 10, // < 20%
          batteryState: BatteryState.discharging,
          powerSource: PowerSource.battery,
          temperatureCelsius: 45.0, // > 42.0°C
        ),
      );

      final alerts = thresholds.evaluate(snapshot);
      expect(alerts.any((a) => a.title == 'High Battery Temperature'), isTrue);
      expect(alerts.any((a) => a.title == 'Low Battery Level'), isTrue);

      final thermalAlert =
          alerts.firstWhere((a) => a.title == 'High Battery Temperature');
      expect(thermalAlert.severity, equals(HealthAlertSeverity.critical));
    });

    test('does not trigger low battery alert when charging', () {
      final now = DateTime.now();
      final snapshot = SystemMetricsSnapshot(
        timestamp: now,
        battery: const BatteryInfo(
          batteryLevel: 10,
          batteryState: BatteryState.charging,
          powerSource: PowerSource.ac,
        ),
      );

      final alerts = thresholds.evaluate(snapshot);
      expect(alerts.any((a) => a.title == 'Low Battery Level'), isFalse);
    });

    test('triggers high CPU load alert when system utilization exceeds threshold', () {
      final now = DateTime.now();
      final snapshot = SystemMetricsSnapshot(
        timestamp: now,
        cpu: const CpuInfo(
          architecture: 'arm64',
          logicalCores: 8,
          systemUtilization: 96.5, // > 90%
        ),
      );

      final alerts = thresholds.evaluate(snapshot);
      expect(alerts.any((a) => a.title == 'High CPU Load'), isTrue);
      final cpuAlert = alerts.firstWhere((a) => a.title == 'High CPU Load');
      expect(cpuAlert.severity, equals(HealthAlertSeverity.warning));
      expect(cpuAlert.category, equals(HealthAlertCategory.cpu));
    });

    test('returns empty list when all metrics are within safe boundaries', () {
      final now = DateTime.now();
      final snapshot = SystemMetricsSnapshot(
        timestamp: now,
        memory: const MemoryInfo(
          totalPhysicalBytes: 8 * 1024 * 1024 * 1024,
          availablePhysicalBytes: 5 * 1024 * 1024 * 1024,
          processResidentBytes: 50 * 1024 * 1024,
          isLowMemory: false,
        ),
        battery: const BatteryInfo(
          batteryLevel: 80,
          batteryState: BatteryState.discharging,
          powerSource: PowerSource.battery,
          temperatureCelsius: 30.0,
        ),
        cpu: const CpuInfo(
          architecture: 'arm64',
          logicalCores: 8,
          systemUtilization: 25.0,
        ),
      );

      final alerts = thresholds.evaluate(snapshot);
      expect(alerts, isEmpty);
    });
  });
}
