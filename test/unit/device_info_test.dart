import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPlatformWithDeviceInfo extends InsideScoopPlatform
    with MockPlatformInterfaceMixin {
  MockPlatformWithDeviceInfo({this.throwError, this.deviceInfo});

  final Object? throwError;
  final DeviceInfo? deviceInfo;

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    if (throwError != null) {
      throw throwError!;
    }
    return deviceInfo ??
        const DeviceInfo(
          model: 'Pixel 8 Pro',
          manufacturer: 'Google',
          brand: 'google',
          category: DeviceCategory.phone,
          isPhysicalDevice: true,
          supportedAbis: ['arm64-v8a'],
        );
  }
}

void main() {
  group('DeviceInfo domain model', () {
    test('instantiates with expected values', () {
      const info = DeviceInfo(
        model: 'iPhone15,3',
        manufacturer: 'Apple',
        brand: 'Apple',
        category: DeviceCategory.phone,
        isPhysicalDevice: true,
        supportedAbis: ['arm64', 'arm64e'],
      );

      expect(info.model, equals('iPhone15,3'));
      expect(info.manufacturer, equals('Apple'));
      expect(info.brand, equals('Apple'));
      expect(info.category, equals(DeviceCategory.phone));
      expect(info.isPhysicalDevice, isTrue);
      expect(info.supportedAbis, contains('arm64'));
    });

    test(
      'DeviceCategory.fromIndex resolves valid indices and defaults to unknown',
      () {
        expect(DeviceCategory.fromIndex(0), equals(DeviceCategory.phone));
        expect(DeviceCategory.fromIndex(1), equals(DeviceCategory.tablet));
        expect(DeviceCategory.fromIndex(2), equals(DeviceCategory.desktop));
        expect(DeviceCategory.fromIndex(3), equals(DeviceCategory.laptop));
        expect(DeviceCategory.fromIndex(4), equals(DeviceCategory.wearable));
        expect(DeviceCategory.fromIndex(5), equals(DeviceCategory.tv));
        expect(DeviceCategory.fromIndex(6), equals(DeviceCategory.unknown));
        expect(DeviceCategory.fromIndex(99), equals(DeviceCategory.unknown));
        expect(DeviceCategory.fromIndex(-1), equals(DeviceCategory.unknown));
      },
    );

    test('serialization toMap and fromMap', () {
      const original = DeviceInfo(
        model: 'MacBookPro18,1',
        manufacturer: 'Apple',
        brand: 'Apple',
        category: DeviceCategory.laptop,
        isPhysicalDevice: true,
        supportedAbis: ['arm64'],
      );

      final map = original.toMap();
      final fromMap = DeviceInfo.fromMap(map);

      expect(fromMap, equals(original));
      expect(fromMap.toJson(), equals(original.toJson()));
    });

    test('copyWith updates specified fields only', () {
      const original = DeviceInfo(
        model: 'GenericPhone',
        manufacturer: 'Generic',
        brand: 'GenericBrand',
        category: DeviceCategory.phone,
        isPhysicalDevice: false,
      );

      final updated = original.copyWith(
        model: 'Pixel 9',
        isPhysicalDevice: true,
      );

      expect(updated.model, equals('Pixel 9'));
      expect(updated.isPhysicalDevice, isTrue);
      expect(updated.manufacturer, equals('Generic'));
      expect(updated.category, equals(DeviceCategory.phone));
    });

    test('equality and hash code check', () {
      const a = DeviceInfo(
        model: 'A',
        manufacturer: 'M',
        brand: 'B',
        category: DeviceCategory.phone,
        isPhysicalDevice: true,
        supportedAbis: ['arm64'],
      );
      const b = DeviceInfo(
        model: 'A',
        manufacturer: 'M',
        brand: 'B',
        category: DeviceCategory.phone,
        isPhysicalDevice: true,
        supportedAbis: ['arm64'],
      );
      const c = DeviceInfo(
        model: 'C',
        manufacturer: 'M',
        brand: 'B',
        category: DeviceCategory.phone,
        isPhysicalDevice: true,
        supportedAbis: ['arm64'],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('model: A'));
    });
  });

  group('DeviceService', () {
    test(
      'info() returns ScoopAvailable when platform query succeeds',
      () async {
        final mockPlatform = MockPlatformWithDeviceInfo();
        final service = DeviceService(mockPlatform);

        final result = await service.info();
        expect(result.isAvailable, isTrue);
        expect(result.valueOrNull?.model, equals('Pixel 8 Pro'));
        expect(result.valueOrNull?.category, equals(DeviceCategory.phone));

        final direct = await service.infoOrNull();
        expect(direct?.model, equals('Pixel 8 Pro'));
      },
    );

    test('info() returns ScoopUnavailable with permissionDenied on permission error', () async {
      final mockPlatform = MockPlatformWithDeviceInfo(
        throwError: PlatformException(
          code: 'permission-denied',
          message: 'Restricted',
        ),
      );
      final service = DeviceService(mockPlatform);

      final result = await service.info();
      expect(result.isUnavailable, isTrue);
      final unavailable = result as ScoopUnavailable<DeviceInfo>;
      expect(
        unavailable.reason,
        equals(ScoopUnavailableReason.permissionDenied),
      );
      expect(await service.infoOrNull(), isNull);
    });

    test('info() returns ScoopUnavailable with unsupportedOnPlatform on UnsupportedError', () async {
      final mockPlatform = MockPlatformWithDeviceInfo(
        throwError: UnsupportedError('Device info not supported'),
      );
      final service = DeviceService(mockPlatform);

      final result = await service.info();
      expect(result.isUnavailable, isTrue);
      final unavailable = result as ScoopUnavailable<DeviceInfo>;
      expect(
        unavailable.reason,
        equals(ScoopUnavailableReason.unsupportedOnPlatform),
      );
    });

    test(
      'info() returns ScoopUnavailable with internalError on generic exception',
      () async {
        final mockPlatform = MockPlatformWithDeviceInfo(
          throwError: Exception('Internal native error'),
        );
        final service = DeviceService(mockPlatform);

        final result = await service.info();
        expect(result.isUnavailable, isTrue);
        final unavailable = result as ScoopUnavailable<DeviceInfo>;
        expect(
          unavailable.reason,
          equals(ScoopUnavailableReason.internalError),
        );
      },
    );
  });
}
