import 'package:meta/meta.dart';

/// System physical memory (RAM) and application process memory consumption metrics.
@immutable
class MemoryInfo {
  const MemoryInfo({
    required this.totalPhysicalBytes,
    required this.availablePhysicalBytes,
    this.processResidentBytes,
    this.processVirtualBytes,
    required this.isLowMemory,
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
    };
  }

  /// Creates a copy of this [MemoryInfo] with optionally replaced fields.
  MemoryInfo copyWith({
    int? totalPhysicalBytes,
    int? availablePhysicalBytes,
    int? processResidentBytes,
    int? processVirtualBytes,
    bool? isLowMemory,
  }) {
    return MemoryInfo(
      totalPhysicalBytes: totalPhysicalBytes ?? this.totalPhysicalBytes,
      availablePhysicalBytes:
          availablePhysicalBytes ?? this.availablePhysicalBytes,
      processResidentBytes: processResidentBytes ?? this.processResidentBytes,
      processVirtualBytes: processVirtualBytes ?? this.processVirtualBytes,
      isLowMemory: isLowMemory ?? this.isLowMemory,
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
          isLowMemory == other.isLowMemory;

  @override
  int get hashCode => Object.hash(
    totalPhysicalBytes,
    availablePhysicalBytes,
    processResidentBytes,
    processVirtualBytes,
    isLowMemory,
  );

  @override
  String toString() {
    return 'MemoryInfo('
        'total: ${totalPhysicalMb}MB, '
        'available: ${availablePhysicalMb}MB, '
        'used: ${usedPhysicalMb}MB (${usagePercentage.toStringAsFixed(1)}%), '
        'isLowMemory: $isLowMemory)';
  }
}
