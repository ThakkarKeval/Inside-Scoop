import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/gpu_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying GPU specifications, renderer, and graphics API metrics.
class GpuService {
  const GpuService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves GPU hardware and renderer metrics wrapped in a strongly typed [ScoopResult].
  Future<ScoopResult<GpuInfo>> info() async {
    try {
      final gpuInfo = await _effectivePlatform.getGpuInfo();
      return ScoopResult.available(gpuInfo);
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

  /// Convenience method that retrieves GPU metrics or returns `null` if unavailable.
  Future<GpuInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }
}
