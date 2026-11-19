import 'package:meta/meta.dart';

/// Breakdown of memory consumption for the host application process.
@immutable
class ProcessMemoryInfo {
  const ProcessMemoryInfo({
    this.residentSetBytes,
    this.virtualBytes,
    this.totalPssBytes,
    this.javaHeapAllocatedBytes,
    this.javaHeapUsedBytes,
  });

  /// Current process resident memory (Resident Set Size - RSS) in bytes.
  final int? residentSetBytes;

  /// Current process virtual memory size in bytes.
  final int? virtualBytes;

  /// Total Proportional Set Size (PSS) in bytes (e.g. Android).
  final int? totalPssBytes;

  /// Java / ART heap allocated memory in bytes, if applicable (e.g. Android).
  final int? javaHeapAllocatedBytes;

  /// Java / ART heap currently in-use memory in bytes, if applicable (e.g. Android).
  final int? javaHeapUsedBytes;

  /// Resident memory in Megabytes (MB).
  int? get residentSetMb =>
      residentSetBytes != null ? (residentSetBytes! / (1024 * 1024)).round() : null;

  /// Virtual memory in Megabytes (MB).
  int? get virtualMb =>
      virtualBytes != null ? (virtualBytes! / (1024 * 1024)).round() : null;

  /// Proportional Set Size in Megabytes (MB).
  int? get totalPssMb =>
      totalPssBytes != null ? (totalPssBytes! / (1024 * 1024)).round() : null;

  /// Java / ART heap allocated in Megabytes (MB).
  int? get javaHeapAllocatedMb =>
      javaHeapAllocatedBytes != null
          ? (javaHeapAllocatedBytes! / (1024 * 1024)).round()
          : null;

  /// Java / ART heap in-use in Megabytes (MB).
  int? get javaHeapUsedMb =>
      javaHeapUsedBytes != null
          ? (javaHeapUsedBytes! / (1024 * 1024)).round()
          : null;

  /// Creates a [ProcessMemoryInfo] from a JSON-compatible map.
  factory ProcessMemoryInfo.fromMap(Map<String, dynamic> map) {
    return ProcessMemoryInfo(
      residentSetBytes: (map['residentSetBytes'] as num?)?.toInt(),
      virtualBytes: (map['virtualBytes'] as num?)?.toInt(),
      totalPssBytes: (map['totalPssBytes'] as num?)?.toInt(),
      javaHeapAllocatedBytes: (map['javaHeapAllocatedBytes'] as num?)?.toInt(),
      javaHeapUsedBytes: (map['javaHeapUsedBytes'] as num?)?.toInt(),
    );
  }

  /// Converts this [ProcessMemoryInfo] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'residentSetBytes': residentSetBytes,
      'virtualBytes': virtualBytes,
      'totalPssBytes': totalPssBytes,
      'javaHeapAllocatedBytes': javaHeapAllocatedBytes,
      'javaHeapUsedBytes': javaHeapUsedBytes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessMemoryInfo &&
          runtimeType == other.runtimeType &&
          residentSetBytes == other.residentSetBytes &&
          virtualBytes == other.virtualBytes &&
          totalPssBytes == other.totalPssBytes &&
          javaHeapAllocatedBytes == other.javaHeapAllocatedBytes &&
          javaHeapUsedBytes == other.javaHeapUsedBytes;

  @override
  int get hashCode => Object.hash(
    residentSetBytes,
    virtualBytes,
    totalPssBytes,
    javaHeapAllocatedBytes,
    javaHeapUsedBytes,
  );

  @override
  String toString() {
    return 'ProcessMemoryInfo('
        'rss: ${residentSetMb != null ? '${residentSetMb}MB' : 'N/A'}, '
        'pss: ${totalPssMb != null ? '${totalPssMb}MB' : 'N/A'}, '
        'jvmUsed: ${javaHeapUsedMb != null ? '${javaHeapUsedMb}MB' : 'N/A'})';
  }
}

/// System physical memory (RAM) and application process memory consumption metrics.
@immutable
class MemoryInfo {
  const MemoryInfo({
    required this.totalPhysicalBytes,
    required this.availablePhysicalBytes,
    this.processResidentBytes,
    this.processVirtualBytes,
    required this.isLowMemory,
    this.totalPssBytes,
    this.jvmHeapAllocatedBytes,
    this.jvmHeapUsedBytes,
  });

  /// Total installed physical system memory in bytes.
  final int totalPhysicalBytes;

  /// Available / free physical system memory in bytes.
  final int availablePhysicalBytes;

  /// Current process resident memory (Resident Set Size) in bytes, if accessible.
  final int? processResidentBytes;

  /// Current process virtual memory in bytes, if accessible.
  final int? processVirtualBytes;

  /// Whether the operating system is experiencing low-memory pressure.
  final bool isLowMemory;

  /// Current process proportional memory (Proportional Set Size) in bytes, if accessible.
  final int? totalPssBytes;

  /// JVM / ART heap allocated memory in bytes, if applicable (e.g. Android).
  final int? jvmHeapAllocatedBytes;

  /// JVM / ART heap currently in-use memory in bytes, if applicable (e.g. Android).
  final int? jvmHeapUsedBytes;

  /// Detailed process-level memory breakdown, if available.
  ProcessMemoryInfo? get process =>
      (processResidentBytes != null ||
              processVirtualBytes != null ||
              totalPssBytes != null ||
              jvmHeapAllocatedBytes != null ||
              jvmHeapUsedBytes != null)
          ? ProcessMemoryInfo(
            residentSetBytes: processResidentBytes,
            virtualBytes: processVirtualBytes,
            totalPssBytes: totalPssBytes,
            javaHeapAllocatedBytes: jvmHeapAllocatedBytes,
            javaHeapUsedBytes: jvmHeapUsedBytes,
          )
          : null;

  /// Calculated used physical system memory in bytes.
  int get usedPhysicalBytes =>
      (totalPhysicalBytes >= availablePhysicalBytes)
          ? totalPhysicalBytes - availablePhysicalBytes
          : 0;

  /// Total physical memory in Megabytes (MB).
  int get totalPhysicalMb => (totalPhysicalBytes / (1024 * 1024)).round();

  /// Available physical memory in Megabytes (MB).
  int get availablePhysicalMb =>
      (availablePhysicalBytes / (1024 * 1024)).round();

  /// Used physical memory in Megabytes (MB).
  int get usedPhysicalMb => (usedPhysicalBytes / (1024 * 1024)).round();

  /// Total physical memory in Gigabytes (GB).
  double get totalPhysicalGb => totalPhysicalBytes / (1024 * 1024 * 1024);

  /// Available physical memory in Gigabytes (GB).
  double get availablePhysicalGb =>
      availablePhysicalBytes / (1024 * 1024 * 1024);

  /// Physical memory usage percentage from 0.0 to 100.0.
  double get usagePercentage =>
      totalPhysicalBytes > 0
          ? ((usedPhysicalBytes / totalPhysicalBytes) * 100).clamp(0.0, 100.0)
          : 0.0;

  /// Creates a [MemoryInfo] from a JSON-compatible map.
  factory MemoryInfo.fromMap(Map<String, dynamic> map) {
    return MemoryInfo(
      totalPhysicalBytes: (map['totalPhysicalBytes'] as num?)?.toInt() ?? 0,
      availablePhysicalBytes:
          (map['availablePhysicalBytes'] as num?)?.toInt() ?? 0,
      processResidentBytes: (map['processResidentBytes'] as num?)?.toInt(),
      processVirtualBytes: (map['processVirtualBytes'] as num?)?.toInt(),
      isLowMemory: map['isLowMemory'] as bool? ?? false,
      totalPssBytes: (map['totalPssBytes'] as num?)?.toInt(),
      jvmHeapAllocatedBytes: (map['jvmHeapAllocatedBytes'] as num?)?.toInt(),
      jvmHeapUsedBytes: (map['jvmHeapUsedBytes'] as num?)?.toInt(),
    );
  }

  /// Converts this [MemoryInfo] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'totalPhysicalBytes': totalPhysicalBytes,
      'availablePhysicalBytes': availablePhysicalBytes,
      'usedPhysicalBytes': usedPhysicalBytes,
      'processResidentBytes': processResidentBytes,
      'processVirtualBytes': processVirtualBytes,
      'isLowMemory': isLowMemory,
      'usagePercentage': usagePercentage,
      'totalPssBytes': totalPssBytes,
      'jvmHeapAllocatedBytes': jvmHeapAllocatedBytes,
      'jvmHeapUsedBytes': jvmHeapUsedBytes,
      if (process != null) 'process': process!.toMap(),
    };
  }

  /// Creates a copy of this [MemoryInfo] with optionally replaced fields.
  MemoryInfo copyWith({
    int? totalPhysicalBytes,
    int? availablePhysicalBytes,
    int? processResidentBytes,
    int? processVirtualBytes,
    bool? isLowMemory,
    int? totalPssBytes,
    int? jvmHeapAllocatedBytes,
    int? jvmHeapUsedBytes,
  }) {
    return MemoryInfo(
      totalPhysicalBytes: totalPhysicalBytes ?? this.totalPhysicalBytes,
      availablePhysicalBytes:
          availablePhysicalBytes ?? this.availablePhysicalBytes,
      processResidentBytes: processResidentBytes ?? this.processResidentBytes,
      processVirtualBytes: processVirtualBytes ?? this.processVirtualBytes,
      isLowMemory: isLowMemory ?? this.isLowMemory,
      totalPssBytes: totalPssBytes ?? this.totalPssBytes,
      jvmHeapAllocatedBytes:
          jvmHeapAllocatedBytes ?? this.jvmHeapAllocatedBytes,
      jvmHeapUsedBytes: jvmHeapUsedBytes ?? this.jvmHeapUsedBytes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryInfo &&
          runtimeType == other.runtimeType &&
          totalPhysicalBytes == other.totalPhysicalBytes &&
          availablePhysicalBytes == other.availablePhysicalBytes &&
          processResidentBytes == other.processResidentBytes &&
          processVirtualBytes == other.processVirtualBytes &&
          isLowMemory == other.isLowMemory &&
          totalPssBytes == other.totalPssBytes &&
          jvmHeapAllocatedBytes == other.jvmHeapAllocatedBytes &&
          jvmHeapUsedBytes == other.jvmHeapUsedBytes;

  @override
  int get hashCode => Object.hash(
    totalPhysicalBytes,
    availablePhysicalBytes,
    processResidentBytes,
    processVirtualBytes,
    isLowMemory,
    totalPssBytes,
    jvmHeapAllocatedBytes,
    jvmHeapUsedBytes,
  );

  @override
  String toString() {
    return 'MemoryInfo('
        'total: ${totalPhysicalMb}MB, '
        'available: ${availablePhysicalMb}MB, '
        'used: ${usedPhysicalMb}MB (${usagePercentage.toStringAsFixed(1)}%), '
        'isLowMemory: $isLowMemory, '
        'process: $process)';
  }
}
