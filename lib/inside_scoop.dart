import 'inside_scoop_platform_interface.dart';

export 'src/core/capabilities/capability.dart';
export 'src/core/errors/scoop_exception.dart';
export 'src/core/errors/scoop_result.dart';

/// The primary entry point for inside_scoop system information APIs.
class InsideScoop {
  /// Retrieves the platform version string (initial baseline API).
  Future<String?> getPlatformVersion() {
    return InsideScoopPlatform.instance.getPlatformVersion();
  }
}
