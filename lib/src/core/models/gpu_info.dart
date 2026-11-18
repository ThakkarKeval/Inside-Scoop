import 'package:meta/meta.dart';

/// Graphics Processing Unit (GPU) hardware, renderer, graphics API, and VRAM specifications.
@immutable
class GpuInfo {
  const GpuInfo({
    required this.vendor,
    required this.renderer,
    this.apiFamily,
    this.apiVersion,
    this.totalVramBytes,
    this.isUnifiedMemory,
  });

  /// The GPU manufacturer or vendor string (e.g. 'Apple', 'Qualcomm', 'ARM', 'NVIDIA', 'Intel', 'AMD').
  final String vendor;

  /// The graphics processor or renderer model string (e.g. 'Apple M2 Pro', 'Adreno (TM) 740', 'NVIDIA GeForce RTX 4080').
  final String renderer;

  /// The primary graphics API family utilized (e.g. 'Metal', 'OpenGL ES', 'DirectX', 'Vulkan', 'WebGL').
  final String? apiFamily;

  /// The graphics API or driver version string.
  final String? apiVersion;

  /// Total dedicated or maximum allocatable Video RAM (VRAM) in bytes, if accessible.
  final int? totalVramBytes;

  /// Whether the graphics processor utilizes unified system memory shared with the CPU.
  final bool? isUnifiedMemory;

  /// Total VRAM in Megabytes (MB), if accessible.
  int? get totalVramMb =>
      totalVramBytes != null
          ? (totalVramBytes! / (1024 * 1024)).round()
          : null;

  /// Total VRAM in Gigabytes (GB), if accessible.
  double? get totalVramGb =>
      totalVramBytes != null
          ? totalVramBytes! / (1024 * 1024 * 1024)
          : null;

  /// Creates a [GpuInfo] from a JSON-compatible map.
  factory GpuInfo.fromMap(Map<String, dynamic> map) {
    return GpuInfo(
      vendor: map['vendor'] as String? ?? 'unknown',
      renderer: map['renderer'] as String? ?? 'unknown',
      apiFamily: map['apiFamily'] as String?,
      apiVersion: map['apiVersion'] as String?,
      totalVramBytes: (map['totalVramBytes'] as num?)?.toInt(),
      isUnifiedMemory: map['isUnifiedMemory'] as bool?,
    );
  }

  /// Converts this [GpuInfo] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'vendor': vendor,
      'renderer': renderer,
      'apiFamily': apiFamily,
      'apiVersion': apiVersion,
      'totalVramBytes': totalVramBytes,
      'isUnifiedMemory': isUnifiedMemory,
    };
  }

  /// Creates a copy of this [GpuInfo] with optionally replaced fields.
  GpuInfo copyWith({
    String? vendor,
    String? renderer,
    String? apiFamily,
    String? apiVersion,
    int? totalVramBytes,
    bool? isUnifiedMemory,
  }) {
    return GpuInfo(
      vendor: vendor ?? this.vendor,
      renderer: renderer ?? this.renderer,
      apiFamily: apiFamily ?? this.apiFamily,
      apiVersion: apiVersion ?? this.apiVersion,
      totalVramBytes: totalVramBytes ?? this.totalVramBytes,
      isUnifiedMemory: isUnifiedMemory ?? this.isUnifiedMemory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GpuInfo &&
          runtimeType == other.runtimeType &&
          vendor == other.vendor &&
          renderer == other.renderer &&
          apiFamily == other.apiFamily &&
          apiVersion == other.apiVersion &&
          totalVramBytes == other.totalVramBytes &&
          isUnifiedMemory == other.isUnifiedMemory;

  @override
  int get hashCode => Object.hash(
    vendor,
    renderer,
    apiFamily,
    apiVersion,
    totalVramBytes,
    isUnifiedMemory,
  );

  @override
  String toString() {
    final vramStr =
        totalVramMb != null ? ', VRAM: ${totalVramMb}MB' : '';
    final unifiedStr =
        isUnifiedMemory == true ? ', Unified Memory' : '';
    return 'GpuInfo(vendor: $vendor, renderer: $renderer$vramStr$unifiedStr)';
  }
}
