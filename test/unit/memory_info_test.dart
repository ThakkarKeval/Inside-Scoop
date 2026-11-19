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
      totalPssBytes: 157286400, // 150 MB
      jvmHeapAllocatedBytes: 104857600, // 100 MB
      jvmHeapUsedBytes: 52428800, // 50 MB
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

    test('exposes detailed process memory breakdown via process getter', () {
      final proc = sampleMemory.process;
      expect(proc, isNotNull);
      expect(proc!.residentSetBytes, equals(209715200));
      expect(proc.residentSetMb, equals(200));
      expect(proc.virtualBytes, equals(419430400));
      expect(proc.virtualMb, equals(400));
      expect(proc.totalPssBytes, equals(157286400));
      expect(proc.totalPssMb, equals(150));
      expect(proc.javaHeapAllocatedBytes, equals(104857600));
      expect(proc.javaHeapAllocatedMb, equals(100));
      expect(proc.javaHeapUsedBytes, equals(52428800));
      expect(proc.javaHeapUsedMb, equals(50));
    });

    test('serializes to and from Map accurately', () {
      final map = sampleMemory.toMap();
      expect(map['totalPhysicalBytes'], equals(17179869184));
      expect(map['availablePhysicalBytes'], equals(8589934592));
      expect(map['usedPhysicalBytes'], equals(8589934592));
      expect(map['processResidentBytes'], equals(209715200));
      expect(map['processVirtualBytes'], equals(419430400));
      expect(map['isLowMemory'], isFalse);
      expect(map['totalPssBytes'], equals(157286400));
      expect(map['jvmHeapAllocatedBytes'], equals(104857600));
      expect(map['jvmHeapUsedBytes'], equals(52428800));

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
      expect(zeroMem.process, isNull);
    });

    test('copyWith creates modified copies correctly', () {
      final modified = sampleMemory.copyWith(
        isLowMemory: true,
        availablePhysicalBytes: 1048576,
        totalPssBytes: 200000000,
      );

      expect(modified.isLowMemory, isTrue);
      expect(modified.availablePhysicalBytes, equals(1048576));
      expect(modified.totalPhysicalBytes, equals(sampleMemory.totalPhysicalBytes));
      expect(modified.totalPssBytes, equals(200000000));
      expect(modified.jvmHeapUsedBytes, equals(sampleMemory.jvmHeapUsedBytes));
    });

    test('toString includes formatted MB values', () {
      final str = sampleMemory.toString();
      expect(str, contains('16384MB'));
      expect(str, contains('8192MB'));
      expect(str, contains('50.0%'));
    });
  });

  group('ProcessMemoryInfo', () {
    test('serializes and deserializes independently', () {
      const proc = ProcessMemoryInfo(
        residentSetBytes: 104857600,
        virtualBytes: 209715200,
        totalPssBytes: 78643200,
        javaHeapAllocatedBytes: 52428800,
        javaHeapUsedBytes: 26214400,
      );

      final map = proc.toMap();
      final restored = ProcessMemoryInfo.fromMap(map);
      expect(restored, equals(proc));
      expect(restored.hashCode, equals(proc.hashCode));
      expect(restored.residentSetMb, equals(100));
      expect(restored.virtualMb, equals(200));
      expect(restored.totalPssMb, equals(75));
      expect(restored.javaHeapAllocatedMb, equals(50));
      expect(restored.javaHeapUsedMb, equals(25));
      expect(restored.toString(), contains('rss: 100MB'));
    });
  });
}
