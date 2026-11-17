import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('ScoopCapabilityInfo', () {
    test('isSupported evaluates correctly based on state', () {
      const supported = ScoopCapabilityInfo(
        feature: ScoopFeature.applicationInfo,
        state: ScoopCapabilityState.supported,
      );
      expect(supported.isSupported, isTrue);

      const unsupported = ScoopCapabilityInfo(
        feature: ScoopFeature.batteryMetrics,
        state: ScoopCapabilityState.unsupported,
      );
      expect(unsupported.isSupported, isFalse);

      const restricted = ScoopCapabilityInfo(
        feature: ScoopFeature.networkInfo,
        state: ScoopCapabilityState.restricted,
      );
      expect(restricted.isSupported, isFalse);

      const requiresPerm = ScoopCapabilityInfo(
        feature: ScoopFeature.networkInfo,
        state: ScoopCapabilityState.requiresPermission,
      );
      expect(requiresPerm.isSupported, isFalse);
    });

    test('equality and hashCode', () {
      const c1 = ScoopCapabilityInfo(
        feature: ScoopFeature.cpuSpecifications,
        state: ScoopCapabilityState.supported,
        description: 'Multi-core CPU',
      );
      const c2 = ScoopCapabilityInfo(
        feature: ScoopFeature.cpuSpecifications,
        state: ScoopCapabilityState.supported,
        description: 'Multi-core CPU',
      );
      const c3 = ScoopCapabilityInfo(
        feature: ScoopFeature.cpuSpecifications,
        state: ScoopCapabilityState.unsupported,
      );

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1, isNot(equals(c3)));
      expect(c1.toString(), contains('cpuSpecifications'));
    });
  });
}
