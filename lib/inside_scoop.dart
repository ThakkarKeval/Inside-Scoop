import 'inside_scoop_platform_interface.dart';
import 'src/features/app/app_service.dart';
import 'src/features/capabilities/capabilities_service.dart';
import 'src/features/device/device_service.dart';
import 'src/features/os/os_service.dart';

export 'src/core/capabilities/capability.dart';
export 'src/core/errors/scoop_exception.dart';
export 'src/core/errors/scoop_result.dart';
export 'src/core/models/app_info.dart';
export 'src/core/models/device_info.dart';
export 'src/core/models/os_info.dart';
export 'src/features/app/app_service.dart';
export 'src/features/capabilities/capabilities_service.dart';
export 'src/features/device/device_service.dart';
export 'src/features/os/os_service.dart';

/// The primary entry point for inside_scoop system information APIs.
class InsideScoop {
  InsideScoop([InsideScoopPlatform? platform])
    : _platform = platform,
      app = AppService(platform),
      os = OsService(platform),
      device = DeviceService(platform),
      capabilities = CapabilitiesService(platform);

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Application information service.
  final AppService app;

  /// Operating system metadata service.
  final OsService os;

  /// Hardware and device metadata service.
  final DeviceService device;

  /// System and feature capability detection service.
  final CapabilitiesService capabilities;

  /// Retrieves the platform version string.
  Future<String?> getPlatformVersion() {
    return _effectivePlatform.getPlatformVersion();
  }
}
