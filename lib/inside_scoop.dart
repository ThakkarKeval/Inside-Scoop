import 'inside_scoop_platform_interface.dart';

class InsideScoop {
  Future<String?> getPlatformVersion() {
    return InsideScoopPlatform.instance.getPlatformVersion();
  }
}
