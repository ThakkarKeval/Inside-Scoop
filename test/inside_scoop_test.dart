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
}

void main() {
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
}
