import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_method_channel.dart';
import 'package:inside_scoop/inside_scoop_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInsideScoopPlatform
    with MockPlatformInterfaceMixin
    implements InsideScoopPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<AppInfo> getAppInfo() => Future.value(
        const AppInfo(
          appName: 'InsideScoopMock',
          packageName: 'com.mock.inside_scoop',
          version: '1.0.0',
          buildNumber: '1',
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final InsideScoopPlatform initialPlatform = InsideScoopPlatform.instance;

  test('$MethodChannelInsideScoop is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInsideScoop>());
  });

  test('getPlatformVersion', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    expect(await insideScoopPlugin.getPlatformVersion(), '42');
  });

  test('app.info returns AppInfo from platform instance', () async {
    final InsideScoop insideScoopPlugin = InsideScoop();
    final MockInsideScoopPlatform fakePlatform = MockInsideScoopPlatform();
    InsideScoopPlatform.instance = fakePlatform;

    final result = await insideScoopPlugin.app.info();
    expect(result.isAvailable, isTrue);
    expect(result.valueOrNull?.appName, equals('InsideScoopMock'));
  });
}
