import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('MetricQuality', () {
    test('fromName resolves valid names correctly', () {
      expect(MetricQuality.fromName('measured'), equals(MetricQuality.measured));
      expect(MetricQuality.fromName('estimated'), equals(MetricQuality.estimated));
      expect(MetricQuality.fromName('inferred'), equals(MetricQuality.inferred));
      expect(MetricQuality.fromName('unavailable'), equals(MetricQuality.unavailable));
    });

    test('fromName defaults to unavailable for unknown or null names', () {
      expect(MetricQuality.fromName('random_string'), equals(MetricQuality.unavailable));
      expect(MetricQuality.fromName(null), equals(MetricQuality.unavailable));
    });
  });

  group('SystemMetric', () {
    test('measured factory sets correct properties', () {
      const metric = SystemMetric.measured(42, 'hw_sensor');
      expect(metric.value, equals(42));
      expect(metric.quality, equals(MetricQuality.measured));
      expect(metric.source, equals('hw_sensor'));
      expect(metric.isAvailable, isTrue);
      expect(metric.isUnavailable, isFalse);
      expect(metric.isMeasured, isTrue);
      expect(metric.isEstimated, isFalse);
      expect(metric.isInferred, isFalse);
    });

    test('estimated factory sets correct properties', () {
      const metric = SystemMetric.estimated(85.5, 'os_battery_service');
      expect(metric.value, equals(85.5));
      expect(metric.quality, equals(MetricQuality.estimated));
      expect(metric.source, equals('os_battery_service'));
      expect(metric.isAvailable, isTrue);
      expect(metric.isEstimated, isTrue);
      expect(metric.isMeasured, isFalse);
    });

    test('inferred factory sets correct properties', () {
      const metric = SystemMetric.inferred('arm64', 'abi_heuristic');
      expect(metric.value, equals('arm64'));
      expect(metric.quality, equals(MetricQuality.inferred));
      expect(metric.source, equals('abi_heuristic'));
      expect(metric.isAvailable, isTrue);
      expect(metric.isInferred, isTrue);
    });

    test('unavailable factory sets correct properties', () {
      const metric = SystemMetric<int>.unavailable('unsupportedOnPlatform');
      expect(metric.value, isNull);
      expect(metric.quality, equals(MetricQuality.unavailable));
      expect(metric.source, equals('unsupportedOnPlatform'));
      expect(metric.isAvailable, isFalse);
      expect(metric.isUnavailable, isTrue);
    });

    test('map transforms value when available', () {
      const metric = SystemMetric.measured(10, 'counter');
      final doubled = metric.map((v) => v * 2);
      expect(doubled.value, equals(20));
      expect(doubled.quality, equals(MetricQuality.measured));
      expect(doubled.source, equals('counter'));

      const unavailable = SystemMetric<int>.unavailable('no_data');
      final mappedUnavailable = unavailable.map((v) => v * 2);
      expect(mappedUnavailable.isUnavailable, isTrue);
      expect(mappedUnavailable.value, isNull);
    });

    test('serializes to and from Map accurately', () {
      const original = SystemMetric.measured('test_val', 'kernel');
      final map = original.toMap();
      expect(map['value'], equals('test_val'));
      expect(map['quality'], equals('measured'));
      expect(map['source'], equals('kernel'));

      final restored = SystemMetric<String>.fromMap(map);
      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
      expect(restored.toString(), contains('measured'));
    });

    test('converts from ScoopResult.available', () {
      const result = ScoopResult<int>.available(100);
      final metric = result.toMetric(quality: MetricQuality.measured, source: 'proc_mem');
      expect(metric.value, equals(100));
      expect(metric.quality, equals(MetricQuality.measured));
      expect(metric.source, equals('proc_mem'));
    });

    test('converts from ScoopResult.unavailable', () {
      const result = ScoopResult<int>.unavailable(
        ScoopUnavailableReason.permissionDenied,
        'missing ACCESS_NETWORK_STATE',
      );
      final metric = result.toMetric();
      expect(metric.isUnavailable, isTrue);
      expect(metric.value, isNull);
      expect(metric.source, contains('permissionDenied'));
    });
  });
}
