import 'package:meta/meta.dart';

/// Primary storage volume capacities, available space, and application storage metrics.
@immutable
class StorageInfo {
  const StorageInfo({
    required this.totalBytes,
    required this.availableBytes,
    this.appStorageBytes,
    required this.isRemovable,
  });

  /// Total capacity of the primary storage volume in bytes.
  final int totalBytes;

  /// Available free capacity on the primary storage volume in bytes.
  final int availableBytes;

  /// Estimated internal application data and cache storage consumption in bytes, if accessible.
  final int? appStorageBytes;

  /// Whether the primary storage volume is a removable medium (e.g. SD card or USB drive).
  final bool isRemovable;

  /// Calculated used storage capacity in bytes.
  int get usedBytes =>
      (totalBytes >= availableBytes) ? totalBytes - availableBytes : 0;

  /// Total storage capacity in Gigabytes (GB).
  double get totalGb => totalBytes / (1024 * 1024 * 1024);

  /// Available storage capacity in Gigabytes (GB).
  double get availableGb => availableBytes / (1024 * 1024 * 1024);

  /// Used storage capacity in Gigabytes (GB).
  double get usedGb => usedBytes / (1024 * 1024 * 1024);

  /// Total storage capacity in Megabytes (MB).
  int get totalMb => (totalBytes / (1024 * 1024)).round();

  /// Available storage capacity in Megabytes (MB).
  int get availableMb => (availableBytes / (1024 * 1024)).round();

  /// Used storage capacity in Megabytes (MB).
  int get usedMb => (usedBytes / (1024 * 1024)).round();

  /// Application internal storage consumption in Megabytes (MB), if accessible.
  double? get appStorageMb =>
      appStorageBytes != null ? appStorageBytes! / (1024 * 1024) : null;

  /// Storage usage percentage from 0.0 to 100.0.
  double get usagePercentage =>
      totalBytes > 0
          ? ((usedBytes / totalBytes) * 100).clamp(0.0, 100.0)
          : 0.0;

  /// Creates a [StorageInfo] from a JSON-compatible map.
  factory StorageInfo.fromMap(Map<String, dynamic> map) {
    return StorageInfo(
      totalBytes: (map['totalBytes'] as num?)?.toInt() ?? 0,
      availableBytes: (map['availableBytes'] as num?)?.toInt() ?? 0,
      appStorageBytes: (map['appStorageBytes'] as num?)?.toInt(),
      isRemovable: map['isRemovable'] as bool? ?? false,
    );
  }

  /// Converts this [StorageInfo] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'totalBytes': totalBytes,
      'availableBytes': availableBytes,
      'usedBytes': usedBytes,
      'appStorageBytes': appStorageBytes,
      'isRemovable': isRemovable,
      'usagePercentage': usagePercentage,
    };
  }

  /// Creates a copy of this [StorageInfo] with optionally replaced fields.
  StorageInfo copyWith({
    int? totalBytes,
    int? availableBytes,
    int? appStorageBytes,
    bool? isRemovable,
  }) {
    return StorageInfo(
      totalBytes: totalBytes ?? this.totalBytes,
      availableBytes: availableBytes ?? this.availableBytes,
      appStorageBytes: appStorageBytes ?? this.appStorageBytes,
      isRemovable: isRemovable ?? this.isRemovable,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageInfo &&
          runtimeType == other.runtimeType &&
          totalBytes == other.totalBytes &&
          availableBytes == other.availableBytes &&
          appStorageBytes == other.appStorageBytes &&
          isRemovable == other.isRemovable;

  @override
  int get hashCode => Object.hash(
    totalBytes,
    availableBytes,
    appStorageBytes,
    isRemovable,
  );

  @override
  String toString() {
    return 'StorageInfo('
        'total: ${totalGb.toStringAsFixed(1)}GB, '
        'available: ${availableGb.toStringAsFixed(1)}GB, '
        'used: ${usedGb.toStringAsFixed(1)}GB (${usagePercentage.toStringAsFixed(1)}%), '
        'isRemovable: $isRemovable)';
  }
}
