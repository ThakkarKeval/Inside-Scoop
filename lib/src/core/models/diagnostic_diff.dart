import 'package:meta/meta.dart';

import 'diagnostic_report.dart';

/// Represents the comparative variance and delta between two [DiagnosticReport] snapshots.
///
/// Enables tracking memory leaks, battery consumption, storage consumption,
/// and environmental state mutations over a measured timeframe.
@immutable
class DiagnosticDiff {
  const DiagnosticDiff({
    required this.elapsed,
    this.memoryDeltaBytes,
    this.processResidentDeltaBytes,
    this.totalPssDeltaBytes,
    this.storageDeltaBytes,
    this.appStorageDeltaBytes,
    this.batteryLevelDeltaPercent,
    required this.environmentalChanges,
  });

  /// Duration elapsed between the baseline snapshot and subsequent snapshot.
  final Duration elapsed;

  /// System-wide physical memory change in bytes (positive = memory consumption increased / available RAM dropped).
  final int? memoryDeltaBytes;

  /// Process resident memory (RSS) change in bytes (positive = process RAM expanded).
  final int? processResidentDeltaBytes;

  /// Android Proportional Set Size (PSS) change in bytes.
  final int? totalPssDeltaBytes;

  /// Primary storage available bytes change (negative = storage consumed).
  final int? storageDeltaBytes;

  /// Application internal storage / cache growth in bytes.
  final int? appStorageDeltaBytes;

  /// Battery percentage change (negative = battery drained, positive = battery charged).
  final double? batteryLevelDeltaPercent;

  /// List of state and environment changes observed between the snapshots.
  final List<String> environmentalChanges;

  /// Process resident memory change in Megabytes (MB).
  double? get processResidentDeltaMb => processResidentDeltaBytes != null
      ? processResidentDeltaBytes! / (1024 * 1024)
      : null;

  /// System memory change in Megabytes (MB).
  double? get memoryDeltaMb =>
      memoryDeltaBytes != null ? memoryDeltaBytes! / (1024 * 1024) : null;

  /// Compares two [DiagnosticReport] instances and produces a [DiagnosticDiff].
  factory DiagnosticDiff.compare(DiagnosticReport before, DiagnosticReport after) {
    final elapsed = after.generatedAt.difference(before.generatedAt);

    // 1. Memory deltas
    int? memDelta;
    if (before.memory != null && after.memory != null) {
      memDelta = after.memory!.usedPhysicalBytes - before.memory!.usedPhysicalBytes;
    }

    int? rssDelta;
    if (before.memory?.processResidentBytes != null &&
        after.memory?.processResidentBytes != null) {
      rssDelta = after.memory!.processResidentBytes! -
          before.memory!.processResidentBytes!;
    }

    int? pssDelta;
    if (before.memory?.totalPssBytes != null &&
        after.memory?.totalPssBytes != null) {
      pssDelta = after.memory!.totalPssBytes! - before.memory!.totalPssBytes!;
    }

    // 2. Storage deltas
    int? storageDelta;
    if (before.storage != null && after.storage != null) {
      storageDelta = after.storage!.availableBytes - before.storage!.availableBytes;
    }

    int? appStorageDelta;
    if (before.storage?.appStorageBytes != null &&
        after.storage?.appStorageBytes != null) {
      appStorageDelta =
          after.storage!.appStorageBytes! - before.storage!.appStorageBytes!;
    }

    // 3. Battery delta
    double? batteryDelta;
    if (before.battery?.batteryLevel != null &&
        after.battery?.batteryLevel != null) {
      batteryDelta = (after.battery!.batteryLevel! - before.battery!.batteryLevel!)
          .toDouble();
    }

    // 4. Environmental changes
    final envChanges = <String>[];

    // Network connectivity change
    if (before.network != null && after.network != null) {
      if (before.network!.isConnected != after.network!.isConnected) {
        envChanges.add(
          'Network connection: ${before.network!.isConnected ? "Connected" : "Disconnected"} '
          '-> ${after.network!.isConnected ? "Connected" : "Disconnected"}',
        );
      }
      if (before.network!.primaryType != after.network!.primaryType) {
        envChanges.add(
          'Network medium: ${before.network!.primaryType.name} -> ${after.network!.primaryType.name}',
        );
      }
      if (before.network!.isMetered != after.network!.isMetered) {
        final isMetered = after.network!.isMetered == true;
        envChanges.add(
          'Network metered status changed: ${isMetered ? "Metered" : "Unmetered"}',
        );
      }
    }

    // Battery & Charging state changes
    if (before.battery != null && after.battery != null) {
      if (before.battery!.isCharging != after.battery!.isCharging) {
        envChanges.add(
          'Charging status: ${before.battery!.isCharging ? "Charging" : "Discharging"} '
          '-> ${after.battery!.isCharging ? "Charging" : "Discharging"}',
        );
      }
      if (before.battery!.powerSource != after.battery!.powerSource) {
        envChanges.add(
          'Power source: ${before.battery!.powerSource.name} -> ${after.battery!.powerSource.name}',
        );
      }
      if (before.battery!.isLowPowerMode != after.battery!.isLowPowerMode) {
        final isLowPower = after.battery!.isLowPowerMode == true;
        envChanges.add(
          'Low power mode: ${isLowPower ? "Enabled" : "Disabled"}',
        );
      }
    }

    // Low memory pressure change
    if (before.memory != null && after.memory != null) {
      if (before.memory!.isLowMemory != after.memory!.isLowMemory) {
        envChanges.add(
          'System memory pressure: ${after.memory!.isLowMemory ? "CRITICAL (Low Memory Active)" : "Normal"}',
        );
      }
    }

    return DiagnosticDiff(
      elapsed: elapsed,
      memoryDeltaBytes: memDelta,
      processResidentDeltaBytes: rssDelta,
      totalPssDeltaBytes: pssDelta,
      storageDeltaBytes: storageDelta,
      appStorageDeltaBytes: appStorageDelta,
      batteryLevelDeltaPercent: batteryDelta,
      environmentalChanges: List.unmodifiable(envChanges),
    );
  }

  /// Formats the comparison as a clean human-readable text summary.
  String toFormattedSummary() {
    final buffer = StringBuffer();
    buffer.writeln('=== Diagnostic Comparison (${elapsed.inSeconds}s elapsed) ===');

    if (processResidentDeltaBytes != null) {
      final sign = processResidentDeltaBytes! >= 0 ? '+' : '';
      buffer.writeln(
        'Process Resident (RSS): $sign${processResidentDeltaMb!.toStringAsFixed(2)} MB',
      );
    }

    if (totalPssDeltaBytes != null) {
      final sign = totalPssDeltaBytes! >= 0 ? '+' : '';
      final mb = (totalPssDeltaBytes! / (1024 * 1024)).toStringAsFixed(2);
      buffer.writeln('Process PSS: $sign$mb MB');
    }

    if (memoryDeltaBytes != null) {
      final sign = memoryDeltaBytes! >= 0 ? '+' : '';
      buffer.writeln(
        'System RAM Used: $sign${memoryDeltaMb!.toStringAsFixed(2)} MB',
      );
    }

    if (batteryLevelDeltaPercent != null) {
      final sign = batteryLevelDeltaPercent! >= 0 ? '+' : '';
      buffer.writeln('Battery Delta: $sign${batteryLevelDeltaPercent!}%');
    }

    if (storageDeltaBytes != null) {
      final sign = storageDeltaBytes! >= 0 ? '+' : '';
      final mb = (storageDeltaBytes! / (1024 * 1024)).toStringAsFixed(2);
      buffer.writeln('Storage Available: $sign$mb MB');
    }

    if (appStorageDeltaBytes != null) {
      final sign = appStorageDeltaBytes! >= 0 ? '+' : '';
      final mb = (appStorageDeltaBytes! / (1024 * 1024)).toStringAsFixed(2);
      buffer.writeln('App Storage / Cache: $sign$mb MB');
    }

    if (environmentalChanges.isNotEmpty) {
      buffer.writeln('Environmental Changes:');
      for (final change in environmentalChanges) {
        buffer.writeln('  • $change');
      }
    } else {
      buffer.writeln('Environmental Changes: None');
    }

    return buffer.toString().trimRight();
  }

  /// Formats the comparison as a Markdown block suitable for bug reports.
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('## Diagnostic Comparison');
    buffer.writeln('- **Elapsed Time**: `${elapsed.inSeconds}s`');

    if (processResidentDeltaBytes != null) {
      final sign = processResidentDeltaBytes! >= 0 ? '+' : '';
      buffer.writeln(
        '- **Process Resident Memory (RSS)**: `$sign${processResidentDeltaMb!.toStringAsFixed(2)} MB`',
      );
    }

    if (totalPssDeltaBytes != null) {
      final sign = totalPssDeltaBytes! >= 0 ? '+' : '';
      final mb = (totalPssDeltaBytes! / (1024 * 1024)).toStringAsFixed(2);
      buffer.writeln('- **Process PSS**: `$sign$mb MB`');
    }

    if (memoryDeltaBytes != null) {
      final sign = memoryDeltaBytes! >= 0 ? '+' : '';
      buffer.writeln(
        '- **System Used RAM**: `$sign${memoryDeltaMb!.toStringAsFixed(2)} MB`',
      );
    }

    if (batteryLevelDeltaPercent != null) {
      final sign = batteryLevelDeltaPercent! >= 0 ? '+' : '';
      buffer.writeln('- **Battery**: `$sign${batteryLevelDeltaPercent!}%`');
    }

    if (environmentalChanges.isNotEmpty) {
      buffer.writeln('\n### State Changes');
      for (final change in environmentalChanges) {
        buffer.writeln('- $change');
      }
    }

    return buffer.toString().trimRight();
  }

  /// Converts this [DiagnosticDiff] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'elapsedMilliseconds': elapsed.inMilliseconds,
      'memoryDeltaBytes': memoryDeltaBytes,
      'processResidentDeltaBytes': processResidentDeltaBytes,
      'totalPssDeltaBytes': totalPssDeltaBytes,
      'storageDeltaBytes': storageDeltaBytes,
      'appStorageDeltaBytes': appStorageDeltaBytes,
      'batteryLevelDeltaPercent': batteryLevelDeltaPercent,
      'environmentalChanges': environmentalChanges,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticDiff &&
          runtimeType == other.runtimeType &&
          elapsed == other.elapsed &&
          memoryDeltaBytes == other.memoryDeltaBytes &&
          processResidentDeltaBytes == other.processResidentDeltaBytes &&
          totalPssDeltaBytes == other.totalPssDeltaBytes &&
          storageDeltaBytes == other.storageDeltaBytes &&
          appStorageDeltaBytes == other.appStorageDeltaBytes &&
          batteryLevelDeltaPercent == other.batteryLevelDeltaPercent;

  @override
  int get hashCode => Object.hash(
        elapsed,
        memoryDeltaBytes,
        processResidentDeltaBytes,
        totalPssDeltaBytes,
        storageDeltaBytes,
        appStorageDeltaBytes,
        batteryLevelDeltaPercent,
      );

  @override
  String toString() => toFormattedSummary();
}
