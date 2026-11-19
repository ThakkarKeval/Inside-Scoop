import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('DiagnosticDiff', () {
    test('accurately calculates memory, battery, and storage variances', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      final t1 = DateTime(2026, 1, 1, 12, 1, 30); // 90 seconds later

      final reportA = DiagnosticReport(
        generatedAt: t0,
        memory: const MemoryInfo(
          totalPhysicalBytes: 8 * 1024 * 1024 * 1024,
          availablePhysicalBytes: 4 * 1024 * 1024 * 1024,
          processResidentBytes: 100 * 1024 * 1024, // 100 MB
          totalPssBytes: 80 * 1024 * 1024,
          isLowMemory: false,
        ),
        battery: const BatteryInfo(
          batteryLevel: 80,
          batteryState: BatteryState.discharging,
          powerSource: PowerSource.battery,
          isLowPowerMode: false,
        ),
        storage: const StorageInfo(
          totalBytes: 128 * 1024 * 1024 * 1024,
          availableBytes: 64 * 1024 * 1024 * 1024,
          appStorageBytes: 50 * 1024 * 1024,
          isRemovable: false,
        ),
        network: const NetworkInfo(
          status: NetworkStatus.connected,
          primaryType: NetworkConnectionType.wifi,
          isMetered: false,
        ),
      );

      final reportB = DiagnosticReport(
        generatedAt: t1,
        memory: const MemoryInfo(
          totalPhysicalBytes: 8 * 1024 * 1024 * 1024,
          availablePhysicalBytes: 3800 * 1024 * 1024,
          processResidentBytes: 140 * 1024 * 1024, // +40 MB
          totalPssBytes: 110 * 1024 * 1024,        // +30 MB
          isLowMemory: true,                       // changed!
        ),
        battery: const BatteryInfo(
          batteryLevel: 78,                        // -2%
          batteryState: BatteryState.charging,     // plugged in!
          powerSource: PowerSource.ac,
          isLowPowerMode: true,
        ),
        storage: const StorageInfo(
          totalBytes: 128 * 1024 * 1024 * 1024,
          availableBytes: 63 * 1024 * 1024 * 1024,
          appStorageBytes: 65 * 1024 * 1024,       // +15 MB
          isRemovable: false,
        ),
        network: const NetworkInfo(
          status: NetworkStatus.connected,
          primaryType: NetworkConnectionType.cellular, // switched to cellular!
          isMetered: true,
        ),
      );

      final diff = DiagnosticDiff.compare(reportA, reportB);

      expect(diff.elapsed, equals(const Duration(seconds: 90)));
      expect(diff.processResidentDeltaBytes, equals(40 * 1024 * 1024));
      expect(diff.processResidentDeltaMb, closeTo(40.0, 0.01));
      expect(diff.totalPssDeltaBytes, equals(30 * 1024 * 1024));
      expect(diff.batteryLevelDeltaPercent, equals(-2.0));
      expect(diff.appStorageDeltaBytes, equals(15 * 1024 * 1024));

      // Check environmental changes
      expect(diff.environmentalChanges.length, greaterThanOrEqualTo(4));
      expect(
        diff.environmentalChanges.any((c) => c.contains('cellular')),
        isTrue,
      );
      expect(
        diff.environmentalChanges.any((c) => c.contains('Charging')),
        isTrue,
      );
      expect(
        diff.environmentalChanges.any((c) => c.contains('Low Memory Active')),
        isTrue,
      );

      // Formatted text and markdown outputs
      final summary = diff.toFormattedSummary();
      expect(summary, contains('+40.00 MB'));
      expect(summary, contains('-2.0%'));

      final md = diff.toMarkdown();
      expect(md, contains('## Diagnostic Comparison'));
      expect(md, contains('`90s`'));

      // Test convenience method on DiagnosticReport
      final reportDiff = reportA.diff(reportB);
      expect(reportDiff.processResidentDeltaBytes, equals(diff.processResidentDeltaBytes));
    });

    test('handles missing or partial subsystem reports safely', () {
      final now = DateTime.now();
      final report1 = DiagnosticReport(generatedAt: now);
      final report2 = DiagnosticReport(generatedAt: now.add(const Duration(seconds: 10)));

      final diff = DiagnosticDiff.compare(report1, report2);
      expect(diff.elapsed.inSeconds, equals(10));
      expect(diff.processResidentDeltaBytes, isNull);
      expect(diff.batteryLevelDeltaPercent, isNull);
      expect(diff.environmentalChanges, isEmpty);

      final map = diff.toMap();
      expect(map['elapsedMilliseconds'], equals(10000));
      expect(map['processResidentDeltaBytes'], isNull);
    });
  });
}
