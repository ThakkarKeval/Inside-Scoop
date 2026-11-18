import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_platform_interface.dart';

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
  });
}
