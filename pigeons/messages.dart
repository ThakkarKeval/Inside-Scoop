import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/src/main/kotlin/com/cavernlabs/inside/scoop/inside_scoop/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.cavernlabs.inside.scoop.inside_scoop',
    ),
    swiftOut: [
      'ios/inside_scoop/Sources/inside_scoop/Messages.g.swift',
      'macos/inside_scoop/Sources/inside_scoop/Messages.g.swift',
    ],
    swiftOptions: SwiftOptions(),
    cppHeaderOut: 'windows/messages.g.h',
    cppSourceOut: 'windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'inside_scoop'),
  ),
)
class PlatformAppInfo {
  PlatformAppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.buildSignature,
    this.installerStore,
  });

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String? buildSignature;
  final String? installerStore;
}

@HostApi()
abstract class InsideScoopHostApi {
  String? getPlatformVersion();
  PlatformAppInfo getAppInfo();
}
