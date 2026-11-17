import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/cpu_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying CPU specifications and utilization metrics.
class CpuService {
  const CpuService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves CPU specifications and utilization metrics wrapped in a [ScoopResult].
  Future<ScoopResult<CpuInfo>> info() async {
    try {
      final cpuInfo = await _effectivePlatform.getCpuInfo();
      return ScoopResult.available(cpuInfo);
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

  /// Convenience method that retrieves CPU metadata or returns `null` if unavailable.
  Future<CpuInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }
}
