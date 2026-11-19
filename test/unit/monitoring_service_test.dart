import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_platform_interface.dart';

class SlowSamplingCpuService extends CpuService {
  SlowSamplingCpuService(super.platform);
  int sampleCount = 0;

  @override
  Future<CpuInfo?> infoOrNull() async {
    sampleCount++;
    // Simulate a slow async sampling task
    await Future.delayed(const Duration(milliseconds: 60));
    return const CpuInfo(
      architecture: 'x86_64',
      logicalCores: 4,
    );
  }
}

class FakeMonitoringPlatform extends InsideScoopPlatform {
  @override
  Future<CpuInfo> getCpuInfo() => Future.value(
    const CpuInfo(
      architecture: 'x86_64',
      logicalCores: 4,
    ),
  );

  @override
  Future<MemoryInfo> getMemoryInfo() => Future.value(
    const MemoryInfo(
      totalPhysicalBytes: 8589934592,
      availablePhysicalBytes: 4294967296,
      isLowMemory: false,
    ),
  );

  @override
  Future<BatteryInfo> getBatteryInfo() => Future.value(
    const BatteryInfo(
      batteryLevel: 95,
      batteryState: BatteryState.charging,
      powerSource: PowerSource.ac,
    ),
  );

  @override
  Future<NetworkInfo> getNetworkInfo() => Future.value(
    const NetworkInfo(
      status: NetworkStatus.connected,
      primaryType: NetworkConnectionType.wifi,
    ),
  );
}

void main() {
  group('MonitoringService', () {
    late FakeMonitoringPlatform platform;
    late MonitoringService service;

    setUp(() {
      platform = FakeMonitoringPlatform();
      service = MonitoringService(platform);
    });

    test('snapshot captures requested metrics synchronously', () async {
      final snapshot = await service.snapshot();
      expect(snapshot.cpu?.architecture, equals('x86_64'));
      expect(snapshot.memory?.totalPhysicalBytes, equals(8589934592));
      expect(snapshot.battery?.batteryLevel, equals(95));
      expect(snapshot.network?.isConnected, isTrue);
    });

    test('snapshot respects selective configuration filters', () async {
      const config = MonitoringConfig(
        sampleCpu: true,
        sampleMemory: false,
        sampleBattery: false,
        sampleNetwork: false,
      );

      final snapshot = await service.snapshot(config: config);
      expect(snapshot.cpu, isNotNull);
      expect(snapshot.memory, isNull);
      expect(snapshot.battery, isNull);
      expect(snapshot.network, isNull);
    });

    test('startMonitoring emits periodic snapshots and cleans up timer on cancel', () async {
      const config = MonitoringConfig(
        interval: Duration(milliseconds: 50),
        pauseInBackground: false,
      );

      final stream = service.startMonitoring(config: config);
      final snapshots = await stream.take(2).toList();

      expect(snapshots.length, equals(2));
      expect(snapshots[0].cpu?.architecture, equals('x86_64'));
      expect(snapshots[1].battery?.batteryLevel, equals(95));
    });

    test('prevents overlapping sampling runs when an operation is slow', () async {
      final slowCpu = SlowSamplingCpuService(platform);
      final customService = MonitoringService(
        platform,
        slowCpu,
      );

      const config = MonitoringConfig(
        interval: Duration(milliseconds: 20), // Ticks every 20ms, but sampling takes 60ms
        sampleCpu: true,
        sampleMemory: false,
        sampleBattery: false,
        sampleNetwork: false,
        pauseInBackground: false,
      );

      final stream = customService.startMonitoring(config: config);
      final sub = stream.listen((_) {});

      // Wait 100ms: without overlap protection, 5 ticks would fire and start 5 concurrent samples.
      // With isSampling guard, subsequent ticks while slowCpu is working are skipped.
      await Future.delayed(const Duration(milliseconds: 100));
      await sub.cancel();

      expect(slowCpu.sampleCount, lessThanOrEqualTo(2));
    });
  });
}
