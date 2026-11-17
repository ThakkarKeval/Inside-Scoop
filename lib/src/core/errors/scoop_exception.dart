import 'package:meta/meta.dart';

import 'scoop_result.dart';

/// Base exception thrown when an unrecoverable SDK error occurs.
@immutable
class ScoopException implements Exception {
  const ScoopException(this.message, {this.reason, this.cause});

  /// A descriptive message explaining the failure.
  final String message;

  /// The associated unavailable reason if known.
  final ScoopUnavailableReason? reason;

  /// The underlying platform or system cause.
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('ScoopException: $message');
    if (reason != null) buffer.write(' (reason: $reason)');
    if (cause != null) buffer.write(' [cause: $cause]');
    return buffer.toString();
  }
}
