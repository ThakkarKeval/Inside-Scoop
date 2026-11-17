import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
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

  @override
  Future<PlatformOsInfo> getOsInfo() async => PlatformOsInfo(
    name: 'Linux',
    version: '6.5',
    buildNumber: '6.5.0-generic',
    architecture: 'x86_64',
    kernelVersion: '6.5.0',
  );

  @override
  Future<PlatformDeviceInfo> getDeviceInfo() async => PlatformDeviceInfo(
    model: 'UbuntuStation',
    manufacturer: 'Dell',
    brand: 'XPS',
    categoryIndex: 3, // laptop
    isPhysicalDevice: true,
    supportedAbis: ['x86_64'],
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

  test('getOsInfo converts PlatformOsInfo to OsInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final osInfo = await platform.getOsInfo();
    expect(osInfo.name, equals('Linux'));
    expect(osInfo.version, equals('6.5'));
    expect(osInfo.buildNumber, equals('6.5.0-generic'));
    expect(osInfo.architecture, equals('x86_64'));
    expect(osInfo.kernelVersion, equals('6.5.0'));
  });

  test('getDeviceInfo converts PlatformDeviceInfo to DeviceInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final deviceInfo = await platform.getDeviceInfo();
    expect(deviceInfo.model, equals('UbuntuStation'));
    expect(deviceInfo.manufacturer, equals('Dell'));
    expect(deviceInfo.brand, equals('XPS'));
    expect(deviceInfo.category, equals(DeviceCategory.laptop));
    expect(deviceInfo.isPhysicalDevice, isTrue);
    expect(deviceInfo.supportedAbis, contains('x86_64'));
  });
}
