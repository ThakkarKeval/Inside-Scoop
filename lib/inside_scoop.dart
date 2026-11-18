import 'inside_scoop_platform_interface.dart';
import 'src/features/app/app_service.dart';
import 'src/features/battery/battery_service.dart';
import 'src/features/capabilities/capabilities_service.dart';
import 'src/features/cpu/cpu_service.dart';
import 'src/features/device/device_service.dart';
import 'src/features/gpu/gpu_service.dart';
import 'src/features/memory/memory_service.dart';
import 'src/features/os/os_service.dart';
import 'src/features/storage/storage_service.dart';

export 'src/core/capabilities/capability.dart';
export 'src/core/errors/scoop_exception.dart';
export 'src/core/errors/scoop_result.dart';
export 'src/core/models/app_info.dart';
export 'src/core/models/battery_info.dart';
export 'src/core/models/cpu_info.dart';
export 'src/core/models/device_info.dart';
export 'src/core/models/gpu_info.dart';
export 'src/core/models/memory_info.dart';
export 'src/core/models/os_info.dart';
export 'src/core/models/storage_info.dart';
export 'src/features/app/app_service.dart';
export 'src/features/battery/battery_service.dart';
export 'src/features/capabilities/capabilities_service.dart';
export 'src/features/cpu/cpu_service.dart';
export 'src/features/device/device_service.dart';
export 'src/features/gpu/gpu_service.dart';
export 'src/features/memory/memory_service.dart';
export 'src/features/os/os_service.dart';
export 'src/features/storage/storage_service.dart';

/// The primary entry point for inside_scoop system information APIs.
class InsideScoop {
  InsideScoop([InsideScoopPlatform? platform])
    : _platform = platform,
      app = AppService(platform),
      os = OsService(platform),
      device = DeviceService(platform),
      capabilities = CapabilitiesService(platform),
      cpu = CpuService(platform),
      memory = MemoryService(platform),
      storage = StorageService(platform),
      gpu = GpuService(platform),
      battery = BatteryService(platform);

  final InsideScoopPlatform? _platform;

  InsideScoopPlatform get _effectivePlatform =>
      _platform ?? InsideScoopPlatform.instance;

  /// Application information service.
  final AppService app;

  /// Operating system metadata service.
  final OsService os;

  /// Hardware and device metadata service.
  final DeviceService device;

  /// System and feature capability detection service.
  final CapabilitiesService capabilities;

  /// Processor specifications and CPU utilization service.
  final CpuService cpu;

  /// System physical memory and process RAM consumption service.
  final MemoryService memory;

  /// Primary storage volume capacities and application disk usage service.
  final StorageService storage;

  /// Graphics processing unit (GPU), renderer, and graphics API metrics service.
  final GpuService gpu;

  /// Battery level, charging state, power source, and power saver mode service.
  final BatteryService battery;

  /// Retrieves the platform version string.
  Future<String?> getPlatformVersion() {
    return _effectivePlatform.getPlatformVersion();
  }
}
