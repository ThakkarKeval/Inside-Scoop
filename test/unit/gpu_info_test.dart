import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('GpuInfo', () {
    const sampleGpu = GpuInfo(
      vendor: 'Apple',
      renderer: 'Apple M2 Pro',
      apiFamily: 'Metal',
      apiVersion: 'Metal 3',
      totalVramBytes: 16 * 1024 * 1024 * 1024, // 16 GB
      isUnifiedMemory: true,
    );

    test('calculates VRAM MB and GB metrics correctly', () {
      expect(sampleGpu.vendor, equals('Apple'));
      expect(sampleGpu.renderer, equals('Apple M2 Pro'));
      expect(sampleGpu.apiFamily, equals('Metal'));
      expect(sampleGpu.apiVersion, equals('Metal 3'));
      expect(sampleGpu.totalVramMb, equals(16384));
      expect(sampleGpu.totalVramGb, closeTo(16.0, 0.01));
      expect(sampleGpu.isUnifiedMemory, isTrue);
    });

    test('serializes to and from Map accurately', () {
      final map = sampleGpu.toMap();
      expect(map['vendor'], equals('Apple'));
      expect(map['renderer'], equals('Apple M2 Pro'));
      expect(map['apiFamily'], equals('Metal'));
      expect(map['apiVersion'], equals('Metal 3'));
      expect(map['totalVramBytes'], equals(16 * 1024 * 1024 * 1024));
      expect(map['isUnifiedMemory'], isTrue);

      final restored = GpuInfo.fromMap(map);
      expect(restored, equals(sampleGpu));
      expect(restored.hashCode, equals(sampleGpu.hashCode));
    });

    test('handles null VRAM gracefully', () {
      const genericGpu = GpuInfo(
        vendor: 'ARM',
        renderer: 'Mali-G710',
        apiFamily: 'OpenGL ES',
        apiVersion: '3.2',
        totalVramBytes: null,
        isUnifiedMemory: true,
      );

      expect(genericGpu.totalVramMb, isNull);
      expect(genericGpu.totalVramGb, isNull);
      expect(genericGpu.isUnifiedMemory, isTrue);
    });

    test('copyWith creates modified copies correctly', () {
      final modified = sampleGpu.copyWith(
        vendor: 'NVIDIA',
        renderer: 'GeForce RTX 4090',
        isUnifiedMemory: false,
      );

      expect(modified.vendor, equals('NVIDIA'));
      expect(modified.renderer, equals('GeForce RTX 4090'));
      expect(modified.isUnifiedMemory, isFalse);
      expect(modified.totalVramBytes, equals(sampleGpu.totalVramBytes));
    });

    test('toString includes formatted description', () {
      final str = sampleGpu.toString();
      expect(str, contains('Apple'));
      expect(str, contains('Apple M2 Pro'));
      expect(str, contains('16384MB'));
      expect(str, contains('Unified Memory'));
    });
  });
}
