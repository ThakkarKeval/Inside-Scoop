import 'package:meta/meta.dart';

import 'battery_info.dart';
import 'cpu_info.dart';
import 'memory_info.dart';
import 'network_info.dart';

/// Configuration options controlling the cadence and scope of real-time monitoring sampling.
@immutable
class MonitoringConfig {
  const MonitoringConfig({
    this.interval = const Duration(seconds: 1),
    this.sampleCpu = true,
    this.sampleMemory = true,
    this.sampleBattery = true,
    this.sampleNetwork = true,
    this.pauseInBackground = true,
  });

  /// The frequency at which system performance metrics are sampled.
  final Duration interval;

  /// Whether processor metrics should be included in each snapshot.
  final bool sampleCpu;

  /// Whether physical and process memory metrics should be included in each snapshot.
  final bool sampleMemory;

  /// Whether battery level and power source states should be included in each snapshot.
  final bool sampleBattery;

  /// Whether active network connectivity and interface types should be included in each snapshot.
  final bool sampleNetwork;

  /// Whether the monitoring timer should automatically pause when the app is backgrounded.
  final bool pauseInBackground;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonitoringConfig &&
          runtimeType == other.runtimeType &&
          interval == other.interval &&
          sampleCpu == other.sampleCpu &&
          sampleMemory == other.sampleMemory &&
          sampleBattery == other.sampleBattery &&
          sampleNetwork == other.sampleNetwork &&
          pauseInBackground == other.pauseInBackground;

  @override
  int get hashCode => Object.hash(
    interval,
    sampleCpu,
    sampleMemory,
    sampleBattery,
    sampleNetwork,
    pauseInBackground,
  );
}

/// A comprehensive point-in-time snapshot capturing real-time hardware, resource, and connectivity metrics.
@immutable
class SystemMetricsSnapshot {
  const SystemMetricsSnapshot({
    required this.timestamp,
    this.cpu,
    this.memory,
    this.battery,
    this.network,
  });

  /// The exact moment this system metrics snapshot was recorded.
  final DateTime timestamp;

  /// Processor specifications and CPU utilization at sample time.
  final CpuInfo? cpu;

  /// System physical RAM and process memory usage at sample time.
  final MemoryInfo? memory;

  /// Battery level, charging state, and power source at sample time.
  final BatteryInfo? battery;

  /// Network connectivity status and transmission medium at sample time.
  final NetworkInfo? network;

  /// Converts this [SystemMetricsSnapshot] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'cpu': cpu?.toMap(),
      'memory': memory?.toMap(),
      'battery': battery?.toMap(),
      'network': network?.toMap(),
    };
  }

  /// Creates a [SystemMetricsSnapshot] from a JSON-compatible map.
  factory SystemMetricsSnapshot.fromMap(Map<String, dynamic> map) {
    return SystemMetricsSnapshot(
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
      cpu: map['cpu'] != null
          ? CpuInfo.fromMap(Map<String, dynamic>.from(map['cpu'] as Map))
          : null,
      memory: map['memory'] != null
          ? MemoryInfo.fromMap(Map<String, dynamic>.from(map['memory'] as Map))
          : null,
      battery: map['battery'] != null
          ? BatteryInfo.fromMap(
              Map<String, dynamic>.from(map['battery'] as Map),
            )
          : null,
      network: map['network'] != null
          ? NetworkInfo.fromMap(
              Map<String, dynamic>.from(map['network'] as Map),
            )
          : null,
    );
  }

  /// Creates a copy of this [SystemMetricsSnapshot] with optionally replaced fields.
  SystemMetricsSnapshot copyWith({
    DateTime? timestamp,
    CpuInfo? cpu,
    MemoryInfo? memory,
    BatteryInfo? battery,
    NetworkInfo? network,
  }) {
    return SystemMetricsSnapshot(
      timestamp: timestamp ?? this.timestamp,
      cpu: cpu ?? this.cpu,
      memory: memory ?? this.memory,
      battery: battery ?? this.battery,
      network: network ?? this.network,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMetricsSnapshot &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          cpu == other.cpu &&
          memory == other.memory &&
          battery == other.battery &&
          network == other.network;

  @override
  int get hashCode => Object.hash(timestamp, cpu, memory, battery, network);

  @override
  String toString() {
    return 'SystemMetricsSnapshot(Time: $timestamp, CPU: ${cpu != null}, Memory: ${memory != null}, Battery: ${battery != null}, Network: ${network != null})';
  }
}
