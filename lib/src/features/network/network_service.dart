import 'dart:async';

import 'package:flutter/services.dart';

import '../../core/errors/scoop_result.dart';
import '../../core/models/network_info.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for querying network connectivity status, interface types, and live connection streams.
class NetworkService {
  const NetworkService([InsideScoopPlatform? platform]) : _platform = platform;

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Retrieves a snapshot of the current network connectivity wrapped in a strongly typed [ScoopResult].
  Future<ScoopResult<NetworkInfo>> info() async {
    try {
      final networkInfo = await _effectivePlatform.getNetworkInfo();
      return ScoopResult.available(networkInfo);
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

  /// Convenience method that retrieves the network snapshot or returns `null` if unavailable.
  Future<NetworkInfo?> infoOrNull() async {
    final result = await info();
    return result.valueOrNull;
  }

  /// An observable stream that emits whenever network status, transport medium, or routing configuration changes.
  Stream<NetworkInfo> watch() {
    return _effectivePlatform.watchNetworkInfo();
  }

  /// Convenience alias for [watch].
  Stream<NetworkInfo> get onStatusChanged => watch();
}
