import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop_method_channel.dart';
import 'package:inside_scoop/src/messages.g.dart';

class FakeInsideScoopHostApi extends InsideScoopHostApi {
  @override
  Future<String?> getPlatformVersion() async => '42';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getPlatformVersion', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    expect(await platform.getPlatformVersion(), '42');
  });
}
