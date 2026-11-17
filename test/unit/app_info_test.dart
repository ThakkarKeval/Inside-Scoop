import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPlatformWithAppInfo extends InsideScoopPlatform
    with MockPlatformInterfaceMixin {
  MockPlatformWithAppInfo({this.throwError, this.appInfo});

  final Object? throwError;
  final AppInfo? appInfo;

  @override
  Future<AppInfo> getAppInfo() async {
    if (throwError != null) {
      throw throwError!;
    }
    return appInfo ??
        const AppInfo(
          appName: 'TestApp',
          packageName: 'com.test.app',
          version: '1.2.3',
          buildNumber: '100',
          buildSignature: 'abcdef123456',
          installerStore: 'TestStore',
        );
  }
}

void main() {
  group('AppInfo domain model', () {
    test('instantiates with expected values', () {
      const info = AppInfo(
        appName: 'InsideScoop',
        packageName: 'com.cavernlabs.inside_scoop',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: 'sha256sig',
        installerStore: 'GooglePlay',
      );

      expect(info.appName, equals('InsideScoop'));
      expect(info.packageName, equals('com.cavernlabs.inside_scoop'));
      expect(info.version, equals('1.0.0'));
      expect(info.buildNumber, equals('1'));
      expect(info.buildSignature, equals('sha256sig'));
      expect(info.installerStore, equals('GooglePlay'));
    });

    test('serialization toMap and fromMap', () {
      const original = AppInfo(
        appName: 'InsideScoop',
        packageName: 'com.cavernlabs.inside_scoop',
        version: '2.0.1',
        buildNumber: '42',
        buildSignature: 'hash123',
        installerStore: 'AppStore',
      );

      final map = original.toMap();
      final fromMap = AppInfo.fromMap(map);

      expect(fromMap, equals(original));
      expect(fromMap.toJson(), equals(original.toJson()));
    });

    test('copyWith updates specified fields only', () {
      const original = AppInfo(
        appName: 'OldApp',
        packageName: 'com.old',
        version: '1.0',
        buildNumber: '1',
      );

      final updated = original.copyWith(appName: 'NewApp', version: '2.0');

      expect(updated.appName, equals('NewApp'));
      expect(updated.packageName, equals('com.old'));
      expect(updated.version, equals('2.0'));
      expect(updated.buildNumber, equals('1'));
    });

    test('equality and hash code check', () {
      const a = AppInfo(
        appName: 'A',
        packageName: 'pkg',
        version: '1',
        buildNumber: '1',
      );
      const b = AppInfo(
        appName: 'A',
        packageName: 'pkg',
        version: '1',
        buildNumber: '1',
      );
      const c = AppInfo(
        appName: 'C',
        packageName: 'pkg',
        version: '1',
        buildNumber: '1',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('appName: A'));
    });
  });

  group('AppService', () {
    test(
      'info() returns ScoopAvailable when platform query succeeds',
      () async {
        final mockPlatform = MockPlatformWithAppInfo();
        final service = AppService(mockPlatform);

        final result = await service.info();
        expect(result.isAvailable, isTrue);
        expect(result.valueOrNull?.appName, equals('TestApp'));
        expect(result.valueOrNull?.packageName, equals('com.test.app'));

        final direct = await service.infoOrNull();
        expect(direct?.appName, equals('TestApp'));
      },
    );

    test('info() returns ScoopUnavailable with permissionDenied on permission error', () async {
      final mockPlatform = MockPlatformWithAppInfo(
        throwError: PlatformException(
          code: 'permission-denied',
          message: 'No permission',
        ),
      );
      final service = AppService(mockPlatform);

      final result = await service.info();
      expect(result.isUnavailable, isTrue);
      final unavailable = result as ScoopUnavailable<AppInfo>;
      expect(
        unavailable.reason,
        equals(ScoopUnavailableReason.permissionDenied),
      );
      expect(unavailable.message, contains('No permission'));

      expect(await service.infoOrNull(), isNull);
    });

    test('info() returns ScoopUnavailable with unsupportedOnPlatform on UnsupportedError', () async {
      final mockPlatform = MockPlatformWithAppInfo(
        throwError: UnsupportedError('Platform not supported'),
      );
      final service = AppService(mockPlatform);

      final result = await service.info();
      expect(result.isUnavailable, isTrue);
      final unavailable = result as ScoopUnavailable<AppInfo>;
      expect(
        unavailable.reason,
        equals(ScoopUnavailableReason.unsupportedOnPlatform),
      );
      expect(unavailable.message, contains('Platform not supported'));
    });

    test(
      'info() returns ScoopUnavailable with internalError on generic exception',
      () async {
        final mockPlatform = MockPlatformWithAppInfo(
          throwError: Exception('Crash in native layer'),
        );
        final service = AppService(mockPlatform);

        final result = await service.info();
        expect(result.isUnavailable, isTrue);
        final unavailable = result as ScoopUnavailable<AppInfo>;
        expect(
          unavailable.reason,
          equals(ScoopUnavailableReason.internalError),
        );
      },
    );
  });
}
