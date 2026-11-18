import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('StorageInfo', () {
    const sampleStorage = StorageInfo(
      totalBytes: 256 * 1024 * 1024 * 1024, // 256 GB
      availableBytes: 128 * 1024 * 1024 * 1024, // 128 GB
      appStorageBytes: 524288000, // 500 MB
      isRemovable: false,
    );

    test('calculates used storage and percentages correctly', () {
      expect(sampleStorage.usedBytes, equals(128 * 1024 * 1024 * 1024));
      expect(sampleStorage.totalGb, closeTo(256.0, 0.01));
      expect(sampleStorage.availableGb, closeTo(128.0, 0.01));
      expect(sampleStorage.usedGb, closeTo(128.0, 0.01));
      expect(sampleStorage.usagePercentage, closeTo(50.0, 0.01));
      expect(sampleStorage.appStorageMb, closeTo(500.0, 0.01));
      expect(sampleStorage.isRemovable, isFalse);
    });

    test('serializes to and from Map accurately', () {
      final map = sampleStorage.toMap();
      expect(map['totalBytes'], equals(256 * 1024 * 1024 * 1024));
      expect(map['availableBytes'], equals(128 * 1024 * 1024 * 1024));
      expect(map['usedBytes'], equals(128 * 1024 * 1024 * 1024));
      expect(map['appStorageBytes'], equals(524288000));
      expect(map['isRemovable'], isFalse);

      final restored = StorageInfo.fromMap(map);
      expect(restored, equals(sampleStorage));
      expect(restored.hashCode, equals(sampleStorage.hashCode));
    });

    test('handles zero total bytes safely without division by zero', () {
      const zeroStorage = StorageInfo(
        totalBytes: 0,
        availableBytes: 0,
        isRemovable: false,
      );
      expect(zeroStorage.usedBytes, equals(0));
      expect(zeroStorage.usagePercentage, equals(0.0));
    });

    test('copyWith creates modified copies correctly', () {
      final modified = sampleStorage.copyWith(
        isRemovable: true,
        availableBytes: 64 * 1024 * 1024 * 1024,
      );

      expect(modified.isRemovable, isTrue);
      expect(modified.availableBytes, equals(64 * 1024 * 1024 * 1024));
      expect(modified.totalBytes, equals(sampleStorage.totalBytes));
    });

    test('toString includes formatted GB values', () {
      final str = sampleStorage.toString();
      expect(str, contains('256.0GB'));
      expect(str, contains('128.0GB'));
      expect(str, contains('50.0%'));
    });
  });
}
