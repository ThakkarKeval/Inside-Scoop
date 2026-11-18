import '../../core/capabilities/capability.dart';
import '../../core/models/app_info.dart';
import '../../core/models/battery_info.dart';
import '../../core/models/cpu_info.dart';
import '../../core/models/device_info.dart';
import '../../core/models/diagnostic_report.dart';
import '../../core/models/gpu_info.dart';
import '../../core/models/memory_info.dart';
import '../../core/models/network_info.dart';
import '../../core/models/os_info.dart';
import '../../core/models/storage_info.dart';
import '../app/app_service.dart';
import '../battery/battery_service.dart';
import '../capabilities/capabilities_service.dart';
import '../cpu/cpu_service.dart';
import '../device/device_service.dart';
import '../gpu/gpu_service.dart';
import '../memory/memory_service.dart';
import '../network/network_service.dart';
import '../os/os_service.dart';
import '../storage/storage_service.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for aggregating multi-subsystem diagnostics, applying privacy redactions, and generating exportable reports.
class DiagnosticsService {
  DiagnosticsService([
    InsideScoopPlatform? platform,
    AppService? app,
    OsService? os,
    DeviceService? device,
    CpuService? cpu,
    MemoryService? memory,
    StorageService? storage,
    GpuService? gpu,
    BatteryService? battery,
    NetworkService? network,
    CapabilitiesService? capabilities,
  ])  : _app = app ?? AppService(platform),
        _os = os ?? OsService(platform),
        _device = device ?? DeviceService(platform),
        _cpu = cpu ?? CpuService(platform),
        _memory = memory ?? MemoryService(platform),
        _storage = storage ?? StorageService(platform),
        _gpu = gpu ?? GpuService(platform),
        _battery = battery ?? BatteryService(platform),
        _network = network ?? NetworkService(platform),
        _capabilities = capabilities ?? CapabilitiesService(platform);

  final AppService _app;
  final OsService _os;
  final DeviceService _device;
  final CpuService _cpu;
  final MemoryService _memory;
  final StorageService _storage;
  final GpuService _gpu;
  final BatteryService _battery;
  final NetworkService _network;
  final CapabilitiesService _capabilities;

  /// Generates a unified, privacy-safe diagnostic report capturing all available system domains.
  Future<DiagnosticReport> generateReport({
    DiagnosticOptions options = const DiagnosticOptions(),
  }) async {
    final results = await Future.wait([
      _safeQuery(() => _app.infoOrNull()),
      _safeQuery(() => _os.infoOrNull()),
      _safeQuery(() => _device.infoOrNull()),
      _safeQuery(() => _cpu.infoOrNull()),
      _safeQuery(() => _memory.infoOrNull()),
      _safeQuery(() => _storage.infoOrNull()),
      _safeQuery(() => _gpu.infoOrNull()),
      _safeQuery(() => _battery.infoOrNull()),
      _safeQuery(() => _network.infoOrNull()),
      options.includeCapabilities
          ? _safeQuery(() => _capabilities.getAll())
          : Future.value(null),
    ]);

    var appInfo = results[0] as AppInfo?;
    var deviceInfo = results[2] as DeviceInfo?;

    if (options.maskSignatures && appInfo?.buildSignature != null) {
      final sig = appInfo!.buildSignature!;
      final masked = sig.length > 8 ? '${sig.substring(0, 8)}...[REDACTED]' : '[REDACTED]';
      appInfo = appInfo.copyWith(buildSignature: masked);
    }

    if (options.maskDeviceIdentifiers && deviceInfo != null) {
      deviceInfo = deviceInfo.copyWith(
        model: '[REDACTED_MODEL]',
        brand: '[REDACTED_BRAND]',
      );
    }

    return DiagnosticReport(
      generatedAt: DateTime.now(),
      app: appInfo,
      os: results[1] as OsInfo?,
      device: deviceInfo,
      cpu: results[3] as CpuInfo?,
      memory: results[4] as MemoryInfo?,
      storage: results[5] as StorageInfo?,
      gpu: results[6] as GpuInfo?,
      battery: results[7] as BatteryInfo?,
      network: results[8] as NetworkInfo?,
      capabilities: results[9] as Map<ScoopFeature, ScoopCapabilityInfo>?,
    );
  }

  Future<T?> _safeQuery<T>(Future<T?> Function() query) async {
    try {
      return await query();
    } catch (_) {
      return null;
    }
  }
}
