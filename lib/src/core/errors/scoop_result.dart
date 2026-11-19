import 'package:meta/meta.dart';

import '../models/system_metric.dart';

/// Enumeration of reasons why a specific system information query
/// cannot be fulfilled.
enum ScoopUnavailableReason {
  /// The requested feature is not supported on the target operating system or platform.
  unsupportedOnPlatform,

  /// The host application does not possess the requisite runtime permission to query this data.
  permissionDenied,

  /// Access to the underlying resource is restricted by system security policies or sandboxing.
  restrictedBySystem,

  /// The physical sensor or hardware subsystem is not present on this device.
  sensorNotPresent,

  /// The metric is transiently unavailable (e.g. system is initializing or sampling).
  temporarilyUnavailable,

  /// An unexpected error or failure occurred while querying the native platform.
  internalError,
}

/// A strongly typed, sealed result representing the outcome of a system query.
///
/// System metrics and hardware capabilities vary across desktop, mobile, and web.
/// [ScoopResult] guarantees that unavailable data is explicitly represented
/// rather than returning fabricated defaults or throwing unhandled errors.
@immutable
sealed class ScoopResult<T> {
  const ScoopResult();

  /// Constructs an available result holding [value].
  const factory ScoopResult.available(T value) = ScoopAvailable<T>;

  /// Constructs an unavailable result with a [reason] and an optional descriptive [message].
  const factory ScoopResult.unavailable(
    ScoopUnavailableReason reason, [
    String? message,
  ]) = ScoopUnavailable<T>;

  /// Whether this query completed successfully with valid data.
  bool get isAvailable => this is ScoopAvailable<T>;

  /// Whether this query could not be fulfilled.
  bool get isUnavailable => this is ScoopUnavailable<T>;

  /// Returns the underlying value if available, or `null` otherwise.
  T? get valueOrNull => switch (this) {
    ScoopAvailable(:final value) => value,
    ScoopUnavailable() => null,
  };

  /// Transforms the value if available using [transform], or preserves the unavailable state.
  ScoopResult<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      ScoopAvailable(:final value) => ScoopAvailable<R>(transform(value)),
      ScoopUnavailable(:final reason, :final message) => ScoopUnavailable<R>(
        reason,
        message,
      ),
    };
  }

  /// Pattern-matching utility covering both result branches.
  R when<R>({
    required R Function(T value) available,
    required R Function(ScoopUnavailableReason reason, String? message)
    unavailable,
  }) {
    return switch (this) {
      ScoopAvailable(:final value) => available(value),
      ScoopUnavailable(:final reason, :final message) => unavailable(
        reason,
        message,
      ),
    };
  }

  /// Converts this [ScoopResult] to a [SystemMetric] with an explicit [quality] and optional [source].
  SystemMetric<T> toMetric({
    MetricQuality quality = MetricQuality.measured,
    String? source,
  }) {
    return switch (this) {
      ScoopAvailable(:final value) => SystemMetric<T>(
          value: value,
          quality: quality,
          source: source,
        ),
      ScoopUnavailable(:final reason, :final message) =>
        SystemMetric<T>.unavailable(
          source ?? (message != null ? '${reason.name}: $message' : reason.name),
        ),
    };
  }
}

/// A successful system query result containing [value].
@immutable
final class ScoopAvailable<T> extends ScoopResult<T> {
  const ScoopAvailable(this.value);

  /// The retrieved system information.
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoopAvailable<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ScoopAvailable($value)';
}

/// An unavailable system query result specifying the failure [reason].
@immutable
final class ScoopUnavailable<T> extends ScoopResult<T> {
  const ScoopUnavailable(this.reason, [this.message]);

  /// The categorized reason for unavailability.
  final ScoopUnavailableReason reason;

  /// An optional human-readable message describing the circumstance.
  final String? message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoopUnavailable<T> &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          message == other.message;

  @override
  int get hashCode => Object.hash(reason, message);

  @override
  String toString() => message != null
      ? 'ScoopUnavailable($reason: $message)'
      : 'ScoopUnavailable($reason)';
}
