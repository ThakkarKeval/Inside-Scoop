import 'inside_scoop_platform_interface.dart';
import 'src/features/app/app_service.dart';

export 'src/core/capabilities/capability.dart';
export 'src/core/errors/scoop_exception.dart';
export 'src/core/errors/scoop_result.dart';
export 'src/core/models/app_info.dart';
export 'src/features/app/app_service.dart';

/// The primary entry point for inside_scoop system information APIs.
class InsideScoop {
  InsideScoop([InsideScoopPlatform? platform])
      : _platform = platform,
        app = AppService(platform);

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Application information service.
  final AppService app;

  /// Retrieves the platform version string.
  Future<String?> getPlatformVersion() {
    return _effectivePlatform.getPlatformVersion();
  }
}
