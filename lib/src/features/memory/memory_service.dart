import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/memory_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying system physical memory and process memory metrics.
class MemoryService {
  const MemoryService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves memory metrics wrapped in a strongly typed [ScoopResult].
  Future<ScoopResult<MemoryInfo>> info() async {
    try {
      final memoryInfo = await _effectivePlatform.getMemoryInfo();
      return ScoopResult.available(memoryInfo);
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

  /// Convenience method that retrieves memory metrics or returns `null` if unavailable.
  Future<MemoryInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }
}
