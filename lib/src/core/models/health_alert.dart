import 'package:meta/meta.dart';

import 'system_metrics_snapshot.dart';

/// Severity level of a system health alert.
enum HealthAlertSeverity {
  /// Informational alert regarding environmental or status changes.
  info,

  /// Warning condition indicating potential performance degradation.
  warning,

  /// Critical condition requiring immediate intervention (e.g. OS low memory or high temperature).
  critical,
}

/// Category or subsystem originating the health alert.
enum HealthAlertCategory {
  /// Memory subsystem alerts (e.g. process memory surge or low OS RAM).
  memory,

  /// Battery and thermal subsystem alerts.
  battery,

  /// Processor load or core throttling alerts.
  cpu,

  /// Network connectivity drops or expensive metered transitions.
  network,

  /// Storage capacity exhaustion alerts.
  storage,
}

/// A strongly typed notification describing a performance condition or threshold breach.
@immutable
class HealthAlert {
  const HealthAlert({
    required this.title,
    required this.message,
    required this.severity,
    required this.category,
    required this.timestamp,
    this.metadata = const {},
  });

  /// Short headline of the health alert.
  final String title;

  /// Explanatory description of the condition.
  final String message;

  /// Urgency or severity of this alert.
  final HealthAlertSeverity severity;

  /// Subsystem or domain from which this alert originated.
  final HealthAlertCategory category;

  /// Timestamp when the condition was detected.
  final DateTime timestamp;

  /// Optional contextual key-value metrics associated with the alert.
  final Map<String, dynamic> metadata;

  /// Converts this [HealthAlert] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'severity': severity.name,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthAlert &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          message == other.message &&
          severity == other.severity &&
          category == other.category &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(
        title,
        message,
        severity,
        category,
        timestamp,
      );

  @override
  String toString() =>
      'HealthAlert([${severity.name.toUpperCase()}] $title: $message)';
}

/// Configurable thresholds used to evaluate health alerts from [SystemMetricsSnapshot].
@immutable
class HealthThresholds {
  const HealthThresholds({
    this.lowMemoryTrigger = true,
    this.maxMemoryUsagePercentage = 90.0,
    this.maxProcessResidentMb,
    this.maxBatteryTemperatureCelsius = 45.0,
    this.lowBatteryPercent = 15,
    this.maxCpuUtilizationPercent = 95.0,
  });

  /// Trigger a critical alert when the operating system raises a low-memory warning flag.
  final bool lowMemoryTrigger;

  /// Maximum allowed physical system memory usage percentage before triggering a warning (default: 90.0%).
  final double? maxMemoryUsagePercentage;

  /// Maximum allowed process resident memory in Megabytes before triggering a warning.
  final double? maxProcessResidentMb;

  /// Maximum allowed battery temperature in Celsius before triggering a thermal warning (default: 45.0°C).
  final double? maxBatteryTemperatureCelsius;

  /// Battery level percentage under which a low battery alert is triggered (default: 15%).
  final int? lowBatteryPercent;

  /// Maximum CPU load percentage before triggering an alert (default: 95.0%).
  final double? maxCpuUtilizationPercent;

  /// Evaluates a [SystemMetricsSnapshot] against these thresholds and returns any triggered alerts.
  List<HealthAlert> evaluate(SystemMetricsSnapshot snapshot) {
    final alerts = <HealthAlert>[];
    final now = snapshot.timestamp;

    // 1. Memory evaluations
    final mem = snapshot.memory;
    if (mem != null) {
      if (lowMemoryTrigger && mem.isLowMemory) {
        alerts.add(
          HealthAlert(
            title: 'Critical Low Memory',
            message: 'Operating system is experiencing critical memory pressure.',
            severity: HealthAlertSeverity.critical,
            category: HealthAlertCategory.memory,
            timestamp: now,
            metadata: {
              'availableMb': mem.availablePhysicalMb,
              'usedMb': mem.usedPhysicalMb,
            },
          ),
        );
      }

      if (maxMemoryUsagePercentage != null &&
          mem.totalPhysicalBytes > 0 &&
          mem.usagePercentage >= maxMemoryUsagePercentage!) {
        alerts.add(
          HealthAlert(
            title: 'High RAM Utilization',
            message:
                'Physical memory usage is at ${mem.usagePercentage.toStringAsFixed(1)}% (threshold: ${maxMemoryUsagePercentage}%).',
            severity: HealthAlertSeverity.warning,
            category: HealthAlertCategory.memory,
            timestamp: now,
            metadata: {'usagePercentage': mem.usagePercentage},
          ),
        );
      }

      if (maxProcessResidentMb != null &&
          mem.processResidentBytes != null) {
        final rssMb = mem.processResidentBytes! / (1024 * 1024);
        if (rssMb >= maxProcessResidentMb!) {
          alerts.add(
            HealthAlert(
              title: 'Process Memory Exceeded',
              message:
                  'Process resident memory is ${rssMb.toStringAsFixed(1)} MB (threshold: ${maxProcessResidentMb} MB).',
              severity: HealthAlertSeverity.warning,
              category: HealthAlertCategory.memory,
              timestamp: now,
              metadata: {'residentMb': rssMb},
            ),
          );
        }
      }
    }

    // 2. Battery & Thermal evaluations
    final batt = snapshot.battery;
    if (batt != null) {
      if (maxBatteryTemperatureCelsius != null &&
          batt.temperatureCelsius != null &&
          batt.temperatureCelsius! >= maxBatteryTemperatureCelsius!) {
        alerts.add(
          HealthAlert(
            title: 'High Battery Temperature',
            message:
                'Battery temperature reached ${batt.temperatureCelsius!.toStringAsFixed(1)}°C (threshold: ${maxBatteryTemperatureCelsius}°C).',
            severity: HealthAlertSeverity.critical,
            category: HealthAlertCategory.battery,
            timestamp: now,
            metadata: {'temperatureCelsius': batt.temperatureCelsius},
          ),
        );
      }

      if (lowBatteryPercent != null &&
          batt.batteryLevel != null &&
          !batt.isCharging &&
          batt.batteryLevel! <= lowBatteryPercent!) {
        alerts.add(
          HealthAlert(
            title: 'Low Battery Level',
            message:
                'Battery level is down to ${batt.batteryLevel}% while discharging.',
            severity: HealthAlertSeverity.warning,
            category: HealthAlertCategory.battery,
            timestamp: now,
            metadata: {'batteryLevel': batt.batteryLevel},
          ),
        );
      }
    }

    // 3. CPU evaluations
    final cpu = snapshot.cpu;
    if (cpu != null &&
        maxCpuUtilizationPercent != null &&
        cpu.systemUtilization != null &&
        cpu.systemUtilization! >= maxCpuUtilizationPercent!) {
      alerts.add(
        HealthAlert(
          title: 'High CPU Load',
          message:
              'System CPU utilization reached ${cpu.systemUtilization!.toStringAsFixed(1)}% (threshold: ${maxCpuUtilizationPercent}%).',
          severity: HealthAlertSeverity.warning,
          category: HealthAlertCategory.cpu,
          timestamp: now,
          metadata: {'systemUtilization': cpu.systemUtilization},
        ),
      );
    }

    return List.unmodifiable(alerts);
  }
}
