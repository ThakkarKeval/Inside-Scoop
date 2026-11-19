import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/models/battery_info.dart';
import '../../core/models/cpu_info.dart';
import '../../core/models/memory_info.dart';
import '../../core/models/network_info.dart';
import '../../core/models/system_metrics_snapshot.dart';
import '../battery/battery_service.dart';
import '../cpu/cpu_service.dart';
import '../memory/memory_service.dart';
import '../network/network_service.dart';
import '../../../inside_scoop_platform_interface.dart';

/// Service responsible for periodic, lifecycle-aware system metrics sampling and real-time streams.
class MonitoringService {
  MonitoringService([
    InsideScoopPlatform? platform,
    CpuService? cpuService,
    MemoryService? memoryService,
    BatteryService? batteryService,
    NetworkService? networkService,
  ])  : _cpuService = cpuService ?? CpuService(platform),
        _memoryService = memoryService ?? MemoryService(platform),
        _batteryService = batteryService ?? BatteryService(platform),
        _networkService = networkService ?? NetworkService(platform);

  final CpuService _cpuService;
  final MemoryService _memoryService;
  final BatteryService _batteryService;
  final NetworkService _networkService;

  /// Captures a single consolidated snapshot across all requested performance domains.
  Future<SystemMetricsSnapshot> snapshot({
    MonitoringConfig config = const MonitoringConfig(),
  }) async {
    final futures = await Future.wait([
      config.sampleCpu ? _cpuService.infoOrNull() : Future<CpuInfo?>.value(null),
      config.sampleMemory
          ? _memoryService.infoOrNull()
          : Future<MemoryInfo?>.value(null),
      config.sampleBattery
          ? _batteryService.infoOrNull()
          : Future<BatteryInfo?>.value(null),
      config.sampleNetwork
          ? _networkService.infoOrNull()
          : Future<NetworkInfo?>.value(null),
    ]);

    return SystemMetricsSnapshot(
      timestamp: DateTime.now(),
      cpu: futures[0] as CpuInfo?,
      memory: futures[1] as MemoryInfo?,
      battery: futures[2] as BatteryInfo?,
      network: futures[3] as NetworkInfo?,
    );
  }

  /// Begins a real-time, periodic stream of [SystemMetricsSnapshot].
  ///
  /// - Emits an initial snapshot immediately upon subscription.
  /// - Automatically pauses sampling when the application enters background state (if [MonitoringConfig.pauseInBackground] is true).
  /// - Resumes sampling when the application returns to foreground.
  /// - Completely disposes of timers and listeners when the subscriber cancels.
  Stream<SystemMetricsSnapshot> startMonitoring({
    MonitoringConfig config = const MonitoringConfig(),
  }) {
    late final StreamController<SystemMetricsSnapshot> controller;
    Timer? timer;
    AppLifecycleListener? lifecycleListener;
    bool isSampling = false;

    Future<void> sample() async {
      if (isSampling) return;
      isSampling = true;
      try {
        final currentSnapshot = await snapshot(config: config);
        if (!controller.isClosed) {
          controller.add(currentSnapshot);
        }
      } catch (e, st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
        }
      } finally {
        isSampling = false;
      }
    }

    void startTimer() {
      timer?.cancel();
      timer = Timer.periodic(config.interval, (_) => sample());
    }

    void stopTimer() {
      timer?.cancel();
      timer = null;
    }

    controller = StreamController<SystemMetricsSnapshot>.broadcast(
      onListen: () {
        sample();
        startTimer();

        if (config.pauseInBackground) {
          try {
            final binding = WidgetsBinding.instance;
            // ignore: unnecessary_null_comparison
            if (binding != null) {
              lifecycleListener = AppLifecycleListener(
                onPause: stopTimer,
                onResume: () {
                  if (timer == null && !controller.isClosed) {
                    sample();
                    startTimer();
                  }
                },
              );
            }
          } catch (_) {
            // Graceful fallback for non-Flutter test environments where WidgetsBinding is absent.
          }
        }
      },
      onCancel: () {
        stopTimer();
        lifecycleListener?.dispose();
        lifecycleListener = null;
      },
    );

    return controller.stream;
  }
}
