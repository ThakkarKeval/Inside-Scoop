import 'inside_scoop_platform_interface.dart';
import 'src/features/app/app_service.dart';
import 'src/features/battery/battery_service.dart';
import 'src/features/capabilities/capabilities_service.dart';
import 'src/features/cpu/cpu_service.dart';
import 'src/features/device/device_service.dart';
import 'src/features/diagnostics/diagnostics_service.dart';
import 'src/features/gpu/gpu_service.dart';
import 'src/features/memory/memory_service.dart';
import 'src/features/monitoring/monitoring_service.dart';
import 'src/features/network/network_service.dart';
import 'src/features/os/os_service.dart';
import 'src/features/storage/storage_service.dart';

export 'src/core/capabilities/capability.dart';
export 'src/core/errors/scoop_exception.dart';
export 'src/core/errors/scoop_result.dart';
export 'src/core/models/app_info.dart';
export 'src/core/models/battery_info.dart';
export 'src/core/models/cpu_info.dart';
export 'src/core/models/device_info.dart';
export 'src/core/models/diagnostic_diff.dart';
export 'src/core/models/diagnostic_report.dart';
export 'src/core/models/gpu_info.dart';
export 'src/core/models/memory_info.dart';
export 'src/core/models/network_info.dart';
export 'src/core/models/os_info.dart';
export 'src/core/models/storage_info.dart';
export 'src/core/models/system_metric.dart';
export 'src/core/models/system_metrics_snapshot.dart';
export 'src/features/app/app_service.dart';
export 'src/features/battery/battery_service.dart';
export 'src/features/capabilities/capabilities_service.dart';
export 'src/features/cpu/cpu_service.dart';
export 'src/features/device/device_service.dart';
export 'src/features/diagnostics/diagnostics_service.dart';
export 'src/features/gpu/gpu_service.dart';
export 'src/features/memory/memory_service.dart';
export 'src/features/monitoring/monitoring_service.dart';
export 'src/features/network/network_service.dart';
export 'src/features/os/os_service.dart';
export 'src/features/storage/storage_service.dart';

/// The primary entry point for inside_scoop system information APIs.
class InsideScoop {
  /// Creates a new instance of [InsideScoop].
  ///
  /// Optionally provide a custom [InsideScoopPlatform] for testing.
  InsideScoop([InsideScoopPlatform? platform])
    : _platform = platform,
      _app = AppService(platform),
      _os = OsService(platform),
      _device = DeviceService(platform),
      _capabilities = CapabilitiesService(platform),
      _cpu = CpuService(platform),
      _memory = MemoryService(platform),
      _storage = StorageService(platform),
      _gpu = GpuService(platform),
      _battery = BatteryService(platform),
      _network = NetworkService(platform),
      _monitoring = MonitoringService(platform),
      _diagnostics = DiagnosticsService(platform);

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Default shared singleton instance for convenient access:
  ///
  /// ```dart
  /// final app = await InsideScoop.instance.app.getInfo();
  /// ```
  static final InsideScoop instance = InsideScoop();

  final AppService _app;
  final OsService _os;
  final DeviceService _device;
  final CapabilitiesService _capabilities;
  final CpuService _cpu;
  final MemoryService _memory;
  final StorageService _storage;
  final GpuService _gpu;
  final BatteryService _battery;
  final NetworkService _network;
  final MonitoringService _monitoring;
  final DiagnosticsService _diagnostics;

  /// Application information service.
  AppService get app => _app;

  /// Operating system metadata service.
  OsService get os => _os;

  /// Hardware and device metadata service.
  DeviceService get device => _device;

  /// System and feature capability detection service.
  CapabilitiesService get capabilities => _capabilities;

  /// Processor specifications and CPU utilization service.
  CpuService get cpu => _cpu;

  /// System physical memory and process RAM consumption service.
  MemoryService get memory => _memory;

  /// Primary storage volume capacities and application disk usage service.
  StorageService get storage => _storage;

  /// Graphics processing unit (GPU), renderer, and graphics API metrics service.
  GpuService get gpu => _gpu;

  /// Battery level, charging state, power source, and power saver mode service.
  BatteryService get battery => _battery;

  /// Network connectivity status, active transport mediums, and live observable streams service.
  NetworkService get network => _network;

  /// Continuous, lifecycle-aware system metrics monitoring and snapshot service.
  MonitoringService get monitoring => _monitoring;

  /// Comprehensive diagnostic reporting, privacy redaction, and multi-subsystem aggregation service.
  DiagnosticsService get diagnostics => _diagnostics;

  /// Retrieves the platform version string.
  Future<String?> getPlatformVersion() {
    return _effectivePlatform.getPlatformVersion();
  }
}
