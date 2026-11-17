import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/app_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying application metadata.
class AppService {
  const AppService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves application metadata wrapped in a strongly typed [ScoopResult].
  Future<ScoopResult<AppInfo>> info() async {
    try {
      final appInfo = await _effectivePlatform.getAppInfo();
      return ScoopResult.available(appInfo);
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

  /// Convenience method that retrieves application metadata or returns `null` if unavailable.
  Future<AppInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }
}
