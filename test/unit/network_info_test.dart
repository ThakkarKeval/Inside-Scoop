import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('NetworkInfo', () {
    const sampleNetwork = NetworkInfo(
      status: NetworkStatus.connected,
      primaryType: NetworkConnectionType.wifi,
      availableTypes: [
        NetworkConnectionType.wifi,
        NetworkConnectionType.cellular,
      ],
      isMetered: false,
      isVpnActive: false,
    );

    test('validates connectivity flags and interface properties', () {
      expect(sampleNetwork.isConnected, isTrue);
      expect(sampleNetwork.status, equals(NetworkStatus.connected));
      expect(sampleNetwork.primaryType, equals(NetworkConnectionType.wifi));
      expect(sampleNetwork.availableTypes.length, equals(2));
      expect(sampleNetwork.isMetered, isFalse);
      expect(sampleNetwork.isVpnActive, isFalse);
    });

    test('serializes to and from Map accurately', () {
      final map = sampleNetwork.toMap();
      expect(map['status'], equals('connected'));
      expect(map['statusIndex'], equals(NetworkStatus.connected.index));
      expect(map['primaryType'], equals('wifi'));
      expect(map['primaryTypeIndex'], equals(NetworkConnectionType.wifi.index));
      expect(map['availableTypes'], equals(['wifi', 'cellular']));
      expect(map['availableTypeIndices'], equals([0, 1]));
      expect(map['isMetered'], isFalse);
      expect(map['isVpnActive'], isFalse);

      final restored = NetworkInfo.fromMap(map);
      expect(restored, equals(sampleNetwork));
      expect(restored.hashCode, equals(sampleNetwork.hashCode));
    });

    test('handles disconnected status safely', () {
      const offlineNetwork = NetworkInfo(
        status: NetworkStatus.disconnected,
        primaryType: NetworkConnectionType.none,
        availableTypes: [],
      );

      expect(offlineNetwork.isConnected, isFalse);
      expect(offlineNetwork.status, equals(NetworkStatus.disconnected));
      expect(offlineNetwork.primaryType, equals(NetworkConnectionType.none));
      expect(offlineNetwork.availableTypes, isEmpty);
    });

    test('copyWith creates modified copies correctly', () {
      final modified = sampleNetwork.copyWith(
        primaryType: NetworkConnectionType.vpn,
        isVpnActive: true,
        isMetered: true,
      );

      expect(modified.primaryType, equals(NetworkConnectionType.vpn));
      expect(modified.isVpnActive, isTrue);
      expect(modified.isMetered, isTrue);
      expect(modified.status, equals(sampleNetwork.status));
    });

    test('toString includes formatted description', () {
      final str = sampleNetwork.toString();
      expect(str, contains('connected'));
      expect(str, contains('wifi'));
      expect(str, contains('[wifi, cellular]'));
    });
  });
}
