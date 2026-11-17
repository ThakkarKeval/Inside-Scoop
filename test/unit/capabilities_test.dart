import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('CapabilitiesService', () {
    test('getAll returns capability info for every ScoopFeature', () async {
      const service = CapabilitiesService.custom(
        targetPlatform: TargetPlatform.macOS,
        isWeb: false,
      );

      final all = await service.getAll();
      expect(all.length, equals(ScoopFeature.values.length));
      for (final feature in ScoopFeature.values) {
        expect(all.containsKey(feature), isTrue);
        expect(all[feature]!.feature, equals(feature));
      }
    });

    test(
      'macOS platform has all features supported without mobile sandbox restrictions',
      () async {
        const service = CapabilitiesService.custom(
          targetPlatform: TargetPlatform.macOS,
          isWeb: false,
        );

        for (final feature in ScoopFeature.values) {
          final info = await service.getCapability(feature);
          expect(info.state, equals(ScoopCapabilityState.supported));
          expect(info.isSupported, isTrue);
        }
      },
    );

    test(
      'Android platform restricts system CPU utilization and requires permission for network',
      () async {
        const service = CapabilitiesService.custom(
          targetPlatform: TargetPlatform.android,
          isWeb: false,
        );

        final cpuUtil = await service.getCapability(
          ScoopFeature.cpuUtilization,
        );
        expect(cpuUtil.state, equals(ScoopCapabilityState.restricted));
        expect(cpuUtil.isSupported, isFalse);
        expect(cpuUtil.description, contains('SELinux'));

        final netInfo = await service.getCapability(ScoopFeature.networkInfo);
        expect(netInfo.state, equals(ScoopCapabilityState.requiresPermission));
        expect(netInfo.isSupported, isFalse);
        expect(netInfo.description, contains('ACCESS_NETWORK_STATE'));

        final appInfo = await service.getCapability(
          ScoopFeature.applicationInfo,
        );
        expect(appInfo.state, equals(ScoopCapabilityState.supported));
        expect(appInfo.isSupported, isTrue);

        final battery = await service.getCapability(
          ScoopFeature.batteryMetrics,
        );
        expect(battery.state, equals(ScoopCapabilityState.supported));
        expect(battery.isSupported, isTrue);
      },
    );

    test('iOS platform supports core metrics and hardware', () async {
      const service = CapabilitiesService.custom(
        targetPlatform: TargetPlatform.iOS,
        isWeb: false,
      );

      final cpu = await service.getCapability(ScoopFeature.cpuSpecifications);
      expect(cpu.state, equals(ScoopCapabilityState.supported));

      final battery = await service.getCapability(ScoopFeature.batteryMetrics);
      expect(battery.state, equals(ScoopCapabilityState.supported));

      final net = await service.getCapability(ScoopFeature.networkInfo);
      expect(net.state, equals(ScoopCapabilityState.supported));
    });

    test(
      'Web platform accurately marks unsupported and restricted browser APIs',
      () async {
        const service = CapabilitiesService.custom(isWeb: true);

        final cpuUtil = await service.getCapability(
          ScoopFeature.cpuUtilization,
        );
        expect(cpuUtil.state, equals(ScoopCapabilityState.unsupported));
        expect(cpuUtil.isSupported, isFalse);

        final battery = await service.getCapability(
          ScoopFeature.batteryMetrics,
        );
        expect(battery.state, equals(ScoopCapabilityState.unsupported));
        expect(battery.isSupported, isFalse);

        final cpuSpecs = await service.getCapability(
          ScoopFeature.cpuSpecifications,
        );
        expect(cpuSpecs.state, equals(ScoopCapabilityState.restricted));
        expect(cpuSpecs.isSupported, isFalse);

        final memory = await service.getCapability(ScoopFeature.memoryMetrics);
        expect(memory.state, equals(ScoopCapabilityState.restricted));

        final network = await service.getCapability(ScoopFeature.networkInfo);
        expect(network.state, equals(ScoopCapabilityState.restricted));

        final storage = await service.getCapability(
          ScoopFeature.storageMetrics,
        );
        expect(storage.state, equals(ScoopCapabilityState.supported));

        final gpu = await service.getCapability(ScoopFeature.gpuSpecifications);
        expect(gpu.state, equals(ScoopCapabilityState.supported));
      },
    );

    test(
      'isSupported convenience method returns boolean matching state',
      () async {
        const service = CapabilitiesService.custom(isWeb: true);

        expect(await service.isSupported(ScoopFeature.applicationInfo), isTrue);
        expect(await service.isSupported(ScoopFeature.cpuUtilization), isFalse);
      },
    );

    test('InsideScoop exposes capabilities service instance', () async {
      final scoop = InsideScoop();
      expect(scoop.capabilities, isA<CapabilitiesService>());
      final all = await scoop.capabilities.getAll();
      expect(all.isNotEmpty, isTrue);
    });
  });
}
