import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/os_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying operating system metadata.
class OsService {
  const OsService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves operating system metadata wrapped in a strongly typed [ScoopResult].
  Future<ScoopResult<OsInfo>> info() async {
    try {
      final osInfo = await _effectivePlatform.getOsInfo();
      return ScoopResult.available(osInfo);
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

  /// Convenience method that retrieves operating system metadata or returns `null` if unavailable.
  Future<OsInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }
}
