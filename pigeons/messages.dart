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
  ),
)
@HostApi()
abstract class InsideScoopHostApi {
  String? getPlatformVersion();
}
