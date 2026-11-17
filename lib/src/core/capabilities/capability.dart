import 'package:meta/meta.dart';

/// Categories of system features tracked by inside_scoop.
enum ScoopFeature {
  /// Basic application metadata (name, version, package identifier).
  applicationInfo,

  /// Device hardware metadata (model, manufacturer, product brand).
  deviceInfo,

  /// Operating system metadata (name, version, build number).
  operatingSystemInfo,

  /// CPU static specifications (model, architecture, core counts).
  cpuSpecifications,

  /// CPU dynamic metrics (system and process utilization).
  cpuUtilization,

  /// System and process memory metrics (RAM totals, free, used).
  memoryMetrics,

  /// Storage and filesystem capacity metrics.
  storageMetrics,

  /// GPU hardware specifications and graphics renderer metadata.
  gpuSpecifications,

  /// Battery level, charging state, and power metrics.
  batteryMetrics,

  /// Network interface categories and connection status.
  networkInfo,

  /// Real-time continuous sampling and change streams.
  realtimeMonitoring,

  /// Diagnostic snapshot collection and serialization.
  diagnosticReports,
}

/// The runtime availability state of a specific [ScoopFeature].
enum ScoopCapabilityState {
  /// The feature is fully supported and operational on this device.
  supported,

  /// The feature is not supported on this platform or hardware.
  unsupported,

  /// Access to this feature requires a runtime permission that has not been granted.
  requiresPermission,

  /// Access to this feature is restricted by platform sandboxing or system policies.
  restricted,
}

/// Detailed capability descriptor for a specific [ScoopFeature].
@immutable
class ScoopCapabilityInfo {
  const ScoopCapabilityInfo({
    required this.feature,
    required this.state,
    this.description,
  });

  /// The feature being described.
  final ScoopFeature feature;

  /// The runtime capability state of this feature.
  final ScoopCapabilityState state;

  /// Optional contextual description or notes regarding this capability.
  final String? description;

  /// Whether this capability is currently operational.
  bool get isSupported => state == ScoopCapabilityState.supported;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoopCapabilityInfo &&
          runtimeType == other.runtimeType &&
          feature == other.feature &&
          state == other.state &&
          description == other.description;

  @override
  int get hashCode => Object.hash(feature, state, description);

  @override
  String toString() =>
      'ScoopCapabilityInfo(feature: $feature, state: $state, description: $description)';
}
