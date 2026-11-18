import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/storage_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying storage volume capacities and application disk usage.
class StorageService {
  const StorageService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves storage capacity metrics wrapped in a strongly typed [ScoopResult].
  Future<ScoopResult<StorageInfo>> info() async {
    try {
      final storageInfo = await _effectivePlatform.getStorageInfo();
      return ScoopResult.available(storageInfo);
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

  /// Convenience method that retrieves storage metrics or returns `null` if unavailable.
  Future<StorageInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }
}
