import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop_method_channel.dart';
import 'package:inside_scoop/src/messages.g.dart';

class FakeInsideScoopHostApi extends InsideScoopHostApi {
  @override
  Future<String?> getPlatformVersion() async => '42';

  @override
  Future<PlatformAppInfo> getAppInfo() async => PlatformAppInfo(
    appName: 'TestApp',
    packageName: 'com.test.pkg',
    version: '1.2.3',
    buildNumber: '99',
    buildSignature: 'sig123',
    installerStore: 'Store',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getPlatformVersion', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    expect(await platform.getPlatformVersion(), '42');
  });

  test('getAppInfo converts PlatformAppInfo to AppInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final appInfo = await platform.getAppInfo();
    expect(appInfo.appName, equals('TestApp'));
    expect(appInfo.packageName, equals('com.test.pkg'));
    expect(appInfo.version, equals('1.2.3'));
    expect(appInfo.buildNumber, equals('99'));
    expect(appInfo.buildSignature, equals('sig123'));
    expect(appInfo.installerStore, equals('Store'));
  });
}
