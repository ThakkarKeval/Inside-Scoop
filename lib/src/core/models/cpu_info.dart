import 'package:meta/meta.dart';

/// Hardware CPU architecture, core topology, clock speed, and utilization metrics.
@immutable
class CpuInfo {
  const CpuInfo({
    required this.architecture,
    this.modelName,
    this.physicalCores,
    required this.logicalCores,
    this.maxClockSpeedMhz,
    this.systemUtilization,
    this.processUtilization,
  });

  /// The CPU instruction set architecture (e.g. 'arm64', 'x86_64').
  final String architecture;

  /// The marketing or brand string of the processor (e.g. 'Apple M2 Pro', 'Intel Core i7').
  final String? modelName;

  /// The number of physical CPU cores, if discoverable.
  final int? physicalCores;

  /// The number of logical CPU cores / hardware execution threads.
  final int logicalCores;

  /// The maximum static clock speed in Megahertz (MHz), if accessible.
  final int? maxClockSpeedMhz;

  /// Instantaneous system-wide CPU utilization percentage (0.0 to 100.0), if supported.
  final double? systemUtilization;

  /// Instantaneous current process CPU utilization percentage (0.0 to 100.0), if supported.
  final double? processUtilization;

  /// Creates a [CpuInfo] from a JSON-compatible map.
  factory CpuInfo.fromMap(Map<String, dynamic> map) {
    return CpuInfo(
      architecture: map['architecture'] as String? ?? 'unknown',
      modelName: map['modelName'] as String?,
      physicalCores: (map['physicalCores'] as num?)?.toInt(),
      logicalCores: (map['logicalCores'] as num?)?.toInt() ?? 1,
      maxClockSpeedMhz: (map['maxClockSpeedMhz'] as num?)?.toInt(),
      systemUtilization: (map['systemUtilization'] as num?)?.toDouble(),
      processUtilization: (map['processUtilization'] as num?)?.toDouble(),
    );
  }

  /// Converts this [CpuInfo] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'architecture': architecture,
      'modelName': modelName,
      'physicalCores': physicalCores,
      'logicalCores': logicalCores,
      'maxClockSpeedMhz': maxClockSpeedMhz,
      'systemUtilization': systemUtilization,
      'processUtilization': processUtilization,
    };
  }

  /// Creates a copy of this [CpuInfo] with optionally replaced fields.
  CpuInfo copyWith({
    String? architecture,
    String? modelName,
    int? physicalCores,
    int? logicalCores,
    int? maxClockSpeedMhz,
    double? systemUtilization,
    double? processUtilization,
  }) {
    return CpuInfo(
      architecture: architecture ?? this.architecture,
      modelName: modelName ?? this.modelName,
      physicalCores: physicalCores ?? this.physicalCores,
      logicalCores: logicalCores ?? this.logicalCores,
      maxClockSpeedMhz: maxClockSpeedMhz ?? this.maxClockSpeedMhz,
      systemUtilization: systemUtilization ?? this.systemUtilization,
      processUtilization: processUtilization ?? this.processUtilization,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CpuInfo &&
          runtimeType == other.runtimeType &&
          architecture == other.architecture &&
          modelName == other.modelName &&
          physicalCores == other.physicalCores &&
          logicalCores == other.logicalCores &&
          maxClockSpeedMhz == other.maxClockSpeedMhz &&
          systemUtilization == other.systemUtilization &&
          processUtilization == other.processUtilization;

  @override
  int get hashCode => Object.hash(
    architecture,
    modelName,
    physicalCores,
    logicalCores,
    maxClockSpeedMhz,
    systemUtilization,
    processUtilization,
  );

  @override
  String toString() {
    return 'CpuInfo('
        'architecture: $architecture, '
        'modelName: $modelName, '
        'physicalCores: $physicalCores, '
        'logicalCores: $logicalCores, '
        'maxClockSpeedMhz: $maxClockSpeedMhz, '
        'systemUtilization: $systemUtilization, '
        'processUtilization: $processUtilization)';
  }
}
