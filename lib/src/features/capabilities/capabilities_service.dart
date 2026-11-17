import 'package:flutter/foundation.dart';

import '../../../inside_scoop_platform_interface.dart';
import '../../core/capabilities/capability.dart';

/// Service responsible for querying system and feature capabilities dynamically across platforms.
class CapabilitiesService {
  const CapabilitiesService([InsideScoopPlatform? platform])
    : this._(platform, null, null);

  /// Internal constructor for testing platform-specific capability resolution.
  @visibleForTesting
  const CapabilitiesService.custom({
    InsideScoopPlatform? platform,
    TargetPlatform? targetPlatform,
    bool? isWeb,
  }) : this._(platform, targetPlatform, isWeb);

  const CapabilitiesService._(
    this._platform,
    this._targetPlatform,
    this._isWeb,
  );

  final InsideScoopPlatform? _platform;
  final TargetPlatform? _targetPlatform;
  final bool? _isWeb;

  InsideScoopPlatform get effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  TargetPlatform get _currentPlatform =>
      _targetPlatform ?? defaultTargetPlatform;

  bool get _currentIsWeb => _isWeb ?? kIsWeb;

  /// Returns a detailed [ScoopCapabilityInfo] descriptor for a specific [feature].
  Future<ScoopCapabilityInfo> getCapability(ScoopFeature feature) async {
    final state = _resolveState(feature);
    final description = _resolveDescription(feature, state);
    return ScoopCapabilityInfo(
      feature: feature,
      state: state,
      description: description,
    );
  }

  /// Returns capability descriptors for all [ScoopFeature]s on the current runtime platform.
  Future<Map<ScoopFeature, ScoopCapabilityInfo>> getAll() async {
    final result = <ScoopFeature, ScoopCapabilityInfo>{};
    for (final feature in ScoopFeature.values) {
      result[feature] = await getCapability(feature);
    }
    return result;
  }

  /// Convenience check whether a [feature] is supported and operational on the current platform.
  Future<bool> isSupported(ScoopFeature feature) async {
    final info = await getCapability(feature);
    return info.isSupported;
  }

  ScoopCapabilityState _resolveState(ScoopFeature feature) {
    if (_currentIsWeb) {
      return switch (feature) {
        ScoopFeature.applicationInfo => ScoopCapabilityState.supported,
        ScoopFeature.deviceInfo => ScoopCapabilityState.supported,
        ScoopFeature.operatingSystemInfo => ScoopCapabilityState.supported,
        ScoopFeature.cpuSpecifications => ScoopCapabilityState.restricted,
        ScoopFeature.cpuUtilization => ScoopCapabilityState.unsupported,
        ScoopFeature.memoryMetrics => ScoopCapabilityState.restricted,
        ScoopFeature.storageMetrics => ScoopCapabilityState.supported,
        ScoopFeature.gpuSpecifications => ScoopCapabilityState.supported,
        ScoopFeature.batteryMetrics => ScoopCapabilityState.unsupported,
        ScoopFeature.networkInfo => ScoopCapabilityState.restricted,
        ScoopFeature.realtimeMonitoring => ScoopCapabilityState.supported,
        ScoopFeature.diagnosticReports => ScoopCapabilityState.supported,
      };
    }

    return switch (feature) {
      ScoopFeature.applicationInfo => ScoopCapabilityState.supported,
      ScoopFeature.deviceInfo => ScoopCapabilityState.supported,
      ScoopFeature.operatingSystemInfo => ScoopCapabilityState.supported,
      ScoopFeature.cpuSpecifications => ScoopCapabilityState.supported,
      ScoopFeature.cpuUtilization =>
        _currentPlatform == TargetPlatform.android
            ? ScoopCapabilityState.restricted
            : ScoopCapabilityState.supported,
      ScoopFeature.memoryMetrics => ScoopCapabilityState.supported,
      ScoopFeature.storageMetrics => ScoopCapabilityState.supported,
      ScoopFeature.gpuSpecifications => ScoopCapabilityState.supported,
      ScoopFeature.batteryMetrics => ScoopCapabilityState.supported,
      ScoopFeature.networkInfo =>
        _currentPlatform == TargetPlatform.android
            ? ScoopCapabilityState.requiresPermission
            : ScoopCapabilityState.supported,
      ScoopFeature.realtimeMonitoring => ScoopCapabilityState.supported,
      ScoopFeature.diagnosticReports => ScoopCapabilityState.supported,
    };
  }

  String? _resolveDescription(
    ScoopFeature feature,
    ScoopCapabilityState state,
  ) {
    if (_currentIsWeb) {
      return switch (feature) {
        ScoopFeature.cpuSpecifications =>
          'Web browsers only expose logical core count (navigator.hardwareConcurrency); clock speed and model are restricted.',
        ScoopFeature.cpuUtilization =>
          'Web browsers do not expose CPU utilization to prevent timing attacks and fingerprinting.',
        ScoopFeature.memoryMetrics =>
          'Web browsers restrict memory metrics. Only Chromium browsers provide approximate performance.memory metrics.',
        ScoopFeature.batteryMetrics =>
          'The Battery Status API is deprecated and removed from modern browsers to protect user privacy.',
        ScoopFeature.networkInfo =>
          'Network Information API (navigator.connection) is non-standard and restricted to Chromium browsers.',
        _ => null,
      };
    }

    if (_currentPlatform == TargetPlatform.android) {
      return switch (feature) {
        ScoopFeature.cpuUtilization =>
          'System-wide CPU utilization is restricted on Android 8.0+ due to SELinux /proc/stat sandboxing; process-level metrics remain available.',
        ScoopFeature.networkInfo =>
          'Network state access requires the android.permission.ACCESS_NETWORK_STATE permission.',
        _ => null,
      };
    }

    return null;
  }
}
