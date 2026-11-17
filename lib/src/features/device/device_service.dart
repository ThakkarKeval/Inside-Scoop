import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/device_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying hardware and device metadata.
class DeviceService {
  const DeviceService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves device metadata wrapped in a strongly typed [ScoopResult].
  Future<ScoopResult<DeviceInfo>> info() async {
    try {
      final deviceInfo = await _effectivePlatform.getDeviceInfo();
      return ScoopResult.available(deviceInfo);
    } on PlatformException catch (e) {
      final reason = switch (e.code) {
        'permission-denied' => ScoopUnavailableReason.permissionDenied,
        'unsupported' => ScoopUnavailableReason.unsupportedOnPlatform,
        'restricted' => ScoopUnavailableReason.restrictedBySystem,
        _ => ScoopUnavailableReason.internalError,
      };
      return ScoopResult.unavailable(
        reason,
        e.message ?? e.details?.toString(),
      );
    } on UnsupportedError catch (e) {
      return ScoopResult.unavailable(
        ScoopUnavailableReason.unsupportedOnPlatform,
        e.message,
      );
    } catch (e) {
      return ScoopResult.unavailable(
        ScoopUnavailableReason.internalError,
        e.toString(),
      );
    }
  }

  /// Convenience method that retrieves device metadata or returns `null` if unavailable.
  Future<DeviceInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }
}
