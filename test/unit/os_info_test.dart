import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPlatformWithOsInfo extends InsideScoopPlatform
    with MockPlatformInterfaceMixin {
  MockPlatformWithOsInfo({this.throwError, this.osInfo});

  final Object? throwError;
  final OsInfo? osInfo;

  @override
  Future<OsInfo> getOsInfo() async {
    if (throwError != null) {
      throw throwError!;
    }
    return osInfo ??
        const OsInfo(
          name: 'Android',
          version: '14.0',
          buildNumber: 'UP1A.231005.007',
          architecture: 'arm64-v8a',
          kernelVersion: 'Linux 5.15.0',
        );
  }
}

void main() {
  group('OsInfo domain model', () {
    test('instantiates with expected values', () {
      const info = OsInfo(
        name: 'Android',
        version: '14.0',
        buildNumber: 'UP1A.231005.007',
        architecture: 'arm64',
        kernelVersion: 'Linux 5.15',
      );

      expect(info.name, equals('Android'));
      expect(info.version, equals('14.0'));
      expect(info.buildNumber, equals('UP1A.231005.007'));
      expect(info.architecture, equals('arm64'));
      expect(info.kernelVersion, equals('Linux 5.15'));
    });

    test('serialization toMap and fromMap', () {
      const original = OsInfo(
        name: 'iOS',
        version: '17.4',
        buildNumber: '21E219',
        architecture: 'arm64',
        kernelVersion: 'Darwin 23.4.0',
      );

      final map = original.toMap();
      final fromMap = OsInfo.fromMap(map);

      expect(fromMap, equals(original));
      expect(fromMap.toJson(), equals(original.toJson()));
    });

    test('copyWith updates specified fields only', () {
      const original = OsInfo(
        name: 'Windows',
        version: '10.0',
        buildNumber: '19045',
        architecture: 'x86_64',
      );

      final updated = original.copyWith(version: '11.0', buildNumber: '22631');

      expect(updated.name, equals('Windows'));
      expect(updated.version, equals('11.0'));
      expect(updated.buildNumber, equals('22631'));
      expect(updated.architecture, equals('x86_64'));
    });

    test('equality and hash code check', () {
      const a = OsInfo(
        name: 'macOS',
        version: '14.4',
        buildNumber: '23E214',
        architecture: 'arm64',
      );
      const b = OsInfo(
        name: 'macOS',
        version: '14.4',
        buildNumber: '23E214',
        architecture: 'arm64',
      );
      const c = OsInfo(
        name: 'macOS',
        version: '14.4',
        buildNumber: '23E215',
        architecture: 'arm64',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('name: macOS'));
    });
  });

  group('OsService', () {
    test(
      'info() returns ScoopAvailable when platform query succeeds',
      () async {
        final mockPlatform = MockPlatformWithOsInfo();
        final service = OsService(mockPlatform);

        final result = await service.info();
        expect(result.isAvailable, isTrue);
        expect(result.valueOrNull?.name, equals('Android'));
        expect(result.valueOrNull?.version, equals('14.0'));

        final direct = await service.infoOrNull();
        expect(direct?.name, equals('Android'));
      },
    );

    test('info() returns ScoopUnavailable with permissionDenied on permission error', () async {
      final mockPlatform = MockPlatformWithOsInfo(
        throwError: PlatformException(
          code: 'permission-denied',
          message: 'Denied',
        ),
      );
      final service = OsService(mockPlatform);

      final result = await service.info();
      expect(result.isUnavailable, isTrue);
      final unavailable = result as ScoopUnavailable<OsInfo>;
      expect(
        unavailable.reason,
        equals(ScoopUnavailableReason.permissionDenied),
      );
      expect(await service.infoOrNull(), isNull);
    });

    test('info() returns ScoopUnavailable with unsupportedOnPlatform on UnsupportedError', () async {
      final mockPlatform = MockPlatformWithOsInfo(
        throwError: UnsupportedError('OS unsupported'),
      );
      final service = OsService(mockPlatform);

      final result = await service.info();
      expect(result.isUnavailable, isTrue);
      final unavailable = result as ScoopUnavailable<OsInfo>;
      expect(
        unavailable.reason,
        equals(ScoopUnavailableReason.unsupportedOnPlatform),
      );
    });

    test(
      'info() returns ScoopUnavailable with internalError on generic exception',
      () async {
        final mockPlatform = MockPlatformWithOsInfo(
          throwError: Exception('Fatal native fault'),
        );
        final service = OsService(mockPlatform);

        final result = await service.info();
        expect(result.isUnavailable, isTrue);
        final unavailable = result as ScoopUnavailable<OsInfo>;
        expect(
          unavailable.reason,
          equals(ScoopUnavailableReason.internalError),
        );
      },
    );
  });
}
