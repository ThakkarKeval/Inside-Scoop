import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('CpuInfo', () {
    const sampleCpu = CpuInfo(
      architecture: 'arm64',
      modelName: 'Apple M2 Pro',
      physicalCores: 10,
      logicalCores: 12,
      maxClockSpeedMhz: 3490,
      systemUtilization: 14.5,
      processUtilization: 2.1,
    );

    test('serializes to and from Map accurately', () {
      final map = sampleCpu.toMap();
      expect(map['architecture'], equals('arm64'));
      expect(map['modelName'], equals('Apple M2 Pro'));
      expect(map['physicalCores'], equals(10));
      expect(map['logicalCores'], equals(12));
      expect(map['maxClockSpeedMhz'], equals(3490));
      expect(map['systemUtilization'], equals(14.5));
      expect(map['processUtilization'], equals(2.1));

      final restored = CpuInfo.fromMap(map);
      expect(restored, equals(sampleCpu));
      expect(restored.hashCode, equals(sampleCpu.hashCode));
    });

    test('fromMap handles missing or null optional fields gracefully', () {
      final minimal = CpuInfo.fromMap({'architecture': 'x86_64', 'logicalCores': 8});
      expect(minimal.architecture, equals('x86_64'));
      expect(minimal.logicalCores, equals(8));
      expect(minimal.modelName, isNull);
      expect(minimal.physicalCores, isNull);
      expect(minimal.maxClockSpeedMhz, isNull);
      expect(minimal.systemUtilization, isNull);
      expect(minimal.processUtilization, isNull);
    });

    test('copyWith creates modified copies correctly', () {
      final modified = sampleCpu.copyWith(
        modelName: 'Apple M3 Max',
        physicalCores: 14,
        logicalCores: 16,
      );

      expect(modified.modelName, equals('Apple M3 Max'));
      expect(modified.physicalCores, equals(14));
      expect(modified.logicalCores, equals(16));
      expect(modified.architecture, equals(sampleCpu.architecture));
      expect(modified.maxClockSpeedMhz, equals(sampleCpu.maxClockSpeedMhz));
    });

    test('toString includes key CPU attributes', () {
      final str = sampleCpu.toString();
      expect(str, contains('arm64'));
      expect(str, contains('Apple M2 Pro'));
      expect(str, contains('12'));
    });
  });
}
