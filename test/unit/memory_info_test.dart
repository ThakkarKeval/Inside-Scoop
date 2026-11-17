import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('MemoryInfo', () {
    const sampleMemory = MemoryInfo(
      totalPhysicalBytes: 17179869184, // 16 GB
      availablePhysicalBytes: 8589934592, // 8 GB
      processResidentBytes: 209715200, // 200 MB
      processVirtualBytes: 419430400, // 400 MB
      isLowMemory: false,
    );

    test('calculates used memory and percentages correctly', () {
      expect(sampleMemory.usedPhysicalBytes, equals(8589934592));
      expect(sampleMemory.totalPhysicalMb, equals(16384));
      expect(sampleMemory.availablePhysicalMb, equals(8192));
      expect(sampleMemory.usedPhysicalMb, equals(8192));
      expect(sampleMemory.totalPhysicalGb, closeTo(16.0, 0.01));
      expect(sampleMemory.availablePhysicalGb, closeTo(8.0, 0.01));
      expect(sampleMemory.usagePercentage, closeTo(50.0, 0.01));
      expect(sampleMemory.isLowMemory, isFalse);
    });

    test('serializes to and from Map accurately', () {
      final map = sampleMemory.toMap();
      expect(map['totalPhysicalBytes'], equals(17179869184));
      expect(map['availablePhysicalBytes'], equals(8589934592));
      expect(map['usedPhysicalBytes'], equals(8589934592));
      expect(map['processResidentBytes'], equals(209715200));
      expect(map['processVirtualBytes'], equals(419430400));
      expect(map['isLowMemory'], isFalse);

      final restored = MemoryInfo.fromMap(map);
      expect(restored, equals(sampleMemory));
      expect(restored.hashCode, equals(sampleMemory.hashCode));
    });

    test('handles zero total memory safely without division by zero', () {
      const zeroMem = MemoryInfo(
        totalPhysicalBytes: 0,
        availablePhysicalBytes: 0,
        isLowMemory: false,
      );
      expect(zeroMem.usedPhysicalBytes, equals(0));
      expect(zeroMem.usagePercentage, equals(0.0));
    });

    test('copyWith creates modified copies correctly', () {
      final modified = sampleMemory.copyWith(
        isLowMemory: true,
        availablePhysicalBytes: 1048576,
      );

      expect(modified.isLowMemory, isTrue);
      expect(modified.availablePhysicalBytes, equals(1048576));
      expect(modified.totalPhysicalBytes, equals(sampleMemory.totalPhysicalBytes));
    });

    test('toString includes formatted MB values', () {
      final str = sampleMemory.toString();
      expect(str, contains('16384MB'));
      expect(str, contains('8192MB'));
      expect(str, contains('50.0%'));
    });
  });
}
