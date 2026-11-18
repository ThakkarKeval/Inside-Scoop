import 'dart:convert';

import 'package:meta/meta.dart';

import '../capabilities/capability.dart';
import 'app_info.dart';
import 'battery_info.dart';
import 'cpu_info.dart';
import 'device_info.dart';
import 'gpu_info.dart';
import 'memory_info.dart';
import 'os_info.dart';
import 'network_info.dart';
import 'storage_info.dart';

/// Configuration options controlling privacy protection, signature masking, and subsystem inclusion.
@immutable
class DiagnosticOptions {
  const DiagnosticOptions({
    this.maskSignatures = true,
    this.maskDeviceIdentifiers = false,
    this.includeCapabilities = true,
  });

  /// Whether cryptographic build signatures and certificate fingerprints should be redacted.
  final bool maskSignatures;

  /// Whether hardware model and brand identifiers should be masked.
  final bool maskDeviceIdentifiers;

  /// Whether the complete platform capability and restriction matrix should be included.
  final bool includeCapabilities;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticOptions &&
          runtimeType == other.runtimeType &&
          maskSignatures == other.maskSignatures &&
          maskDeviceIdentifiers == other.maskDeviceIdentifiers &&
          includeCapabilities == other.includeCapabilities;

  @override
  int get hashCode => Object.hash(
    maskSignatures,
    maskDeviceIdentifiers,
    includeCapabilities,
  );
}

/// A comprehensive, consolidated diagnostic report capturing all system metadata and performance metrics.
@immutable
class DiagnosticReport {
  const DiagnosticReport({
    required this.generatedAt,
    this.app,
    this.os,
    this.device,
    this.cpu,
    this.memory,
    this.storage,
    this.gpu,
    this.battery,
    this.network,
    this.capabilities,
  });

  /// The timestamp when this diagnostic report was compiled.
  final DateTime generatedAt;

  /// Application package, version, and installation metadata.
  final AppInfo? app;

  /// Operating system name, version, build, and kernel metadata.
  final OsInfo? os;

  /// Device hardware model, manufacturer, and categorization.
  final DeviceInfo? device;

  /// Processor architecture, core counts, and frequency.
  final CpuInfo? cpu;

  /// Physical and process memory statistics.
  final MemoryInfo? memory;

  /// Primary storage volume capacities and application usage.
  final StorageInfo? storage;

  /// Graphics processing unit, renderer, and graphics API metrics.
  final GpuInfo? gpu;

  /// Battery level, charging status, and power management flags.
  final BatteryInfo? battery;

  /// Network connectivity status and active interfaces.
  final NetworkInfo? network;

  /// Platform feature availability and restriction matrix.
  final Map<ScoopFeature, ScoopCapabilityInfo>? capabilities;

  /// Converts this diagnostic report into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'app': app?.toMap(),
      'os': os?.toMap(),
      'device': device?.toMap(),
      'cpu': cpu?.toMap(),
      'memory': memory?.toMap(),
      'storage': storage?.toMap(),
      'gpu': gpu?.toMap(),
      'battery': battery?.toMap(),
      'network': network?.toMap(),
      'capabilities': capabilities?.map(
        (key, value) => MapEntry(key.name, {
          'state': value.state.name,
          'description': value.description,
        }),
      ),
    };
  }

  /// Serializes this report into a formatted JSON string.
  String toJson({bool pretty = false}) {
    final encoder = pretty ? const JsonEncoder.withIndent('  ') : const JsonEncoder();
    return encoder.convert(toMap());
  }

  /// Creates a [DiagnosticReport] from a JSON-compatible map.
  factory DiagnosticReport.fromMap(Map<String, dynamic> map) {
    Map<ScoopFeature, ScoopCapabilityInfo>? caps;
    if (map['capabilities'] != null) {
      caps = {};
      final rawCaps = Map<String, dynamic>.from(map['capabilities'] as Map);
      for (final entry in rawCaps.entries) {
        final feature = ScoopFeature.values.firstWhere(
          (f) => f.name == entry.key,
          orElse: () => ScoopFeature.applicationInfo,
        );
        final capMap = Map<String, dynamic>.from(entry.value as Map);
        final state = ScoopCapabilityState.values.firstWhere(
          (s) => s.name == capMap['state'],
          orElse: () => ScoopCapabilityState.unsupported,
        );
        caps[feature] = ScoopCapabilityInfo(
          feature: feature,
          state: state,
          description: capMap['description'] as String?,
        );
      }
    }

    return DiagnosticReport(
      generatedAt: DateTime.tryParse(map['generatedAt'] as String? ?? '') ?? DateTime.now(),
      app: map['app'] != null ? AppInfo.fromMap(Map<String, dynamic>.from(map['app'] as Map)) : null,
      os: map['os'] != null ? OsInfo.fromMap(Map<String, dynamic>.from(map['os'] as Map)) : null,
      device: map['device'] != null ? DeviceInfo.fromMap(Map<String, dynamic>.from(map['device'] as Map)) : null,
      cpu: map['cpu'] != null ? CpuInfo.fromMap(Map<String, dynamic>.from(map['cpu'] as Map)) : null,
      memory: map['memory'] != null ? MemoryInfo.fromMap(Map<String, dynamic>.from(map['memory'] as Map)) : null,
      storage: map['storage'] != null ? StorageInfo.fromMap(Map<String, dynamic>.from(map['storage'] as Map)) : null,
      gpu: map['gpu'] != null ? GpuInfo.fromMap(Map<String, dynamic>.from(map['gpu'] as Map)) : null,
      battery: map['battery'] != null ? BatteryInfo.fromMap(Map<String, dynamic>.from(map['battery'] as Map)) : null,
      network: map['network'] != null ? NetworkInfo.fromMap(Map<String, dynamic>.from(map['network'] as Map)) : null,
      capabilities: caps,
    );
  }

  /// Creates a [DiagnosticReport] from a JSON string.
  factory DiagnosticReport.fromJson(String jsonString) {
    return DiagnosticReport.fromMap(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Formats this diagnostic report into a clean, markdown document suitable for GitHub or Jira issues.
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# System Diagnostic Report');
    buffer.writeln('**Generated At:** ${generatedAt.toUtc().toIso8601String()} UTC\n');

    if (app != null) {
      buffer.writeln('## Application Information');
      buffer.writeln('- **Name:** ${app!.appName}');
      buffer.writeln('- **Package:** `${app!.packageName}`');
      buffer.writeln('- **Version:** ${app!.version} (Build: ${app!.buildNumber})');
      if (app!.installerStore != null) {
        buffer.writeln('- **Installer:** ${app!.installerStore}');
      }
      if (app!.buildSignature != null) {
        buffer.writeln('- **Signature:** `${app!.buildSignature}`');
      }
      buffer.writeln();
    }

    if (os != null || device != null) {
      buffer.writeln('## Operating System & Hardware');
      if (os != null) {
        buffer.writeln('- **OS:** ${os!.name} ${os!.version} (${os!.architecture})');
        buffer.writeln('- **Build:** `${os!.buildNumber}`');
        if (os!.kernelVersion != null) {
          buffer.writeln('- **Kernel:** ${os!.kernelVersion}');
        }
      }
      if (device != null) {
        buffer.writeln('- **Device:** ${device!.manufacturer} ${device!.model} (${device!.category.name})');
        buffer.writeln('- **Physical Device:** ${device!.isPhysicalDevice}');
      }
      buffer.writeln();
    }

    if (cpu != null || gpu != null) {
      buffer.writeln('## Processing Units');
      if (cpu != null) {
        buffer.writeln('- **CPU Architecture:** ${cpu!.architecture}');
        if (cpu!.modelName != null) {
          buffer.writeln('- **CPU Model:** ${cpu!.modelName}');
        }
        buffer.writeln('- **Logical Cores:** ${cpu!.logicalCores}${cpu!.physicalCores != null ? " (${cpu!.physicalCores} physical)" : ""}');
        if (cpu!.maxClockSpeedMhz != null) {
          buffer.writeln('- **Max Clock Speed:** ${cpu!.maxClockSpeedMhz} MHz');
        }
      }
      if (gpu != null) {
        buffer.writeln('- **GPU Renderer:** ${gpu!.renderer} (${gpu!.vendor})');
        if (gpu!.apiFamily != null) {
          buffer.writeln('- **Graphics API:** ${gpu!.apiFamily} ${gpu!.apiVersion ?? ""}');
        }
        if (gpu!.totalVramMb != null) {
          buffer.writeln('- **VRAM:** ${gpu!.totalVramMb} MB');
        }
      }
      buffer.writeln();
    }

    if (memory != null || storage != null) {
      buffer.writeln('## Memory & Storage');
      if (memory != null) {
        buffer.writeln('- **Physical RAM:** ${memory!.availablePhysicalMb} MB / ${memory!.totalPhysicalMb} MB available (${memory!.usagePercentage.toStringAsFixed(1)}% used)');
        buffer.writeln('- **Low Memory Warning:** ${memory!.isLowMemory}');
      }
      if (storage != null) {
        buffer.writeln('- **Primary Volume:** ${storage!.availableGb.toStringAsFixed(1)} GB / ${storage!.totalGb.toStringAsFixed(1)} GB free (${storage!.usagePercentage.toStringAsFixed(1)}% used)');
      }
      buffer.writeln();
    }

    if (battery != null || network != null) {
      buffer.writeln('## Power & Connectivity');
      if (battery != null) {
        buffer.writeln('- **Battery:** ${battery!.batteryLevel != null ? "${battery!.batteryLevel}%" : "N/A"} (${battery!.batteryState.name}, Power: ${battery!.powerSource.name})');
        if (battery!.isLowPowerMode != null) {
          buffer.writeln('- **Low Power Mode:** ${battery!.isLowPowerMode}');
        }
      }
      if (network != null) {
        buffer.writeln('- **Network Status:** ${network!.status.name} (${network!.primaryType.name})');
        if (network!.isMetered != null) {
          buffer.writeln('- **Metered:** ${network!.isMetered}');
        }
        if (network!.isVpnActive != null) {
          buffer.writeln('- **VPN:** ${network!.isVpnActive}');
        }
      }
      buffer.writeln();
    }

    if (capabilities != null && capabilities!.isNotEmpty) {
      buffer.writeln('## Platform Capabilities');
      buffer.writeln('| Feature | Support State | Description |');
      buffer.writeln('|---|:---:|---|');
      for (final entry in capabilities!.entries) {
        buffer.writeln('| ${entry.key.name} | ${entry.value.state.name} | ${entry.value.description} |');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Creates a copy of this [DiagnosticReport] with optionally replaced fields.
  DiagnosticReport copyWith({
    DateTime? generatedAt,
    AppInfo? app,
    OsInfo? os,
    DeviceInfo? device,
    CpuInfo? cpu,
    MemoryInfo? memory,
    StorageInfo? storage,
    GpuInfo? gpu,
    BatteryInfo? battery,
    NetworkInfo? network,
    Map<ScoopFeature, ScoopCapabilityInfo>? capabilities,
  }) {
    return DiagnosticReport(
      generatedAt: generatedAt ?? this.generatedAt,
      app: app ?? this.app,
      os: os ?? this.os,
      device: device ?? this.device,
      cpu: cpu ?? this.cpu,
      memory: memory ?? this.memory,
      storage: storage ?? this.storage,
      gpu: gpu ?? this.gpu,
      battery: battery ?? this.battery,
      network: network ?? this.network,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticReport &&
          runtimeType == other.runtimeType &&
          generatedAt == other.generatedAt &&
          app == other.app &&
          os == other.os &&
          device == other.device &&
          cpu == other.cpu &&
          memory == other.memory &&
          storage == other.storage &&
          gpu == other.gpu &&
          battery == other.battery &&
          network == other.network;

  @override
  int get hashCode => Object.hash(
    generatedAt,
    app,
    os,
    device,
    cpu,
    memory,
    storage,
    gpu,
    battery,
    network,
  );

  @override
  String toString() {
    return 'DiagnosticReport(Time: $generatedAt, App: ${app != null}, OS: ${os != null}, Device: ${device != null})';
  }
}
