import 'package:meta/meta.dart';

/// Classifies the accuracy, reliability, and provenance of a system metric.
enum MetricQuality {
  /// Directly measured from underlying hardware sensors, kernel metrics, or authoritative OS syscalls.
  measured,

  /// Estimated or approximated by the operating system, driver, or battery subsystem.
  estimated,

  /// Inferred through platform heuristics (e.g. CPU architecture inferred from binary ABI or model heuristics).
  inferred,

  /// The metric is not available or unsupported in the current platform or environment.
  unavailable;

  /// Returns the enum instance matching the given name, or [MetricQuality.unavailable] as default.
  static MetricQuality fromName(String? name) {
    return MetricQuality.values.firstWhere(
      (q) => q.name == name,
      orElse: () => MetricQuality.unavailable,
    );
  }
}

/// A strongly typed wrapper representing a system metric alongside its quality and source provenance.
@immutable
class SystemMetric<T> {
  const SystemMetric({
    required this.value,
    required this.quality,
    this.source,
  });

  /// Constructs a measured metric from an authoritative [value] and optional [source] descriptor.
  const SystemMetric.measured(T value, [String? source])
      : this(value: value, quality: MetricQuality.measured, source: source);

  /// Constructs an estimated metric from an approximate [value] and optional [source] descriptor.
  const SystemMetric.estimated(T value, [String? source])
      : this(value: value, quality: MetricQuality.estimated, source: source);

  /// Constructs an inferred metric from a heuristically derived [value] and optional [source] descriptor.
  const SystemMetric.inferred(T value, [String? source])
      : this(value: value, quality: MetricQuality.inferred, source: source);

  /// Constructs an unavailable metric with an optional reason [source].
  const SystemMetric.unavailable([String? source])
      : this(value: null, quality: MetricQuality.unavailable, source: source);

  /// The resolved metric value, or `null` if unavailable.
  final T? value;

  /// The confidence and reliability level of this metric.
  final MetricQuality quality;

  /// The underlying mechanism, API, or syscall used to retrieve this metric (e.g. `"/proc/self/status"`, `"sysctlbyname"`).
  final String? source;

  /// Whether this metric has a valid value and is not unavailable.
  bool get isAvailable => quality != MetricQuality.unavailable && value != null;

  /// Whether this metric is unavailable.
  bool get isUnavailable => !isAvailable;

  /// Whether this metric was directly measured from hardware or the OS kernel.
  bool get isMeasured => quality == MetricQuality.measured;

  /// Whether this metric was estimated or approximated.
  bool get isEstimated => quality == MetricQuality.estimated;

  /// Whether this metric was inferred through heuristics.
  bool get isInferred => quality == MetricQuality.inferred;

  /// Maps the underlying [value] if available using [transform].
  SystemMetric<R> map<R>(R Function(T value) transform) {
    if (value != null && isAvailable) {
      return SystemMetric<R>(
        value: transform(value as T),
        quality: quality,
        source: source,
      );
    }
    return SystemMetric<R>.unavailable(source);
  }

  /// Converts this [SystemMetric] into a JSON-compatible map.
  Map<String, dynamic> toMap([dynamic Function(T value)? valueSerializer]) {
    return {
      'value': value != null && valueSerializer != null
          ? valueSerializer(value as T)
          : value,
      'quality': quality.name,
      if (source != null) 'source': source,
    };
  }

  /// Deserializes a [SystemMetric] from a JSON-compatible map.
  factory SystemMetric.fromMap(
    Map<String, dynamic> map, [
    T Function(dynamic raw)? valueParser,
  ]) {
    final rawValue = map['value'];
    final qualityStr = map['quality'] as String?;
    final source = map['source'] as String?;
    final quality = MetricQuality.fromName(qualityStr);

    final parsedValue = (rawValue != null && valueParser != null)
        ? valueParser(rawValue)
        : rawValue as T?;

    return SystemMetric<T>(
      value: parsedValue,
      quality: quality,
      source: source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMetric<T> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          quality == other.quality &&
          source == other.source;

  @override
  int get hashCode => Object.hash(value, quality, source);

  @override
  String toString() =>
      'SystemMetric($value, quality: ${quality.name}${source != null ? ', source: $source' : ''})';
}
