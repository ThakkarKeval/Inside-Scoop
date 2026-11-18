import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/battery_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying battery level, charging status, and power sources.
class BatteryService {
  const BatteryService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves battery and power metrics wrapped in a strongly typed [ScoopResult].
  Future<ScoopResult<BatteryInfo>> info() async {
    try {
      final batteryInfo = await _effectivePlatform.getBatteryInfo();
      return ScoopResult.available(batteryInfo);
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

  /// Convenience method that retrieves battery metrics or returns `null` if unavailable.
  Future<BatteryInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }
}
