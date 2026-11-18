import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('BatteryInfo', () {
    const sampleBattery = BatteryInfo(
      batteryLevel: 85,
      batteryState: BatteryState.charging,
      powerSource: PowerSource.ac,
      isLowPowerMode: false,
      temperatureCelsius: 28.5,
    );

    test('calculates fraction, charging flag, and Fahrenheit correctly', () {
      expect(sampleBattery.batteryLevel, equals(85));
      expect(sampleBattery.batteryFraction, closeTo(0.85, 0.001));
      expect(sampleBattery.isCharging, isTrue);
      expect(sampleBattery.batteryState, equals(BatteryState.charging));
      expect(sampleBattery.powerSource, equals(PowerSource.ac));
      expect(sampleBattery.isLowPowerMode, isFalse);
      expect(sampleBattery.temperatureCelsius, equals(28.5));
      expect(sampleBattery.temperatureFahrenheit, closeTo(83.3, 0.1));
    });

    test('serializes to and from Map accurately', () {
      final map = sampleBattery.toMap();
      expect(map['batteryLevel'], equals(85));
      expect(map['batteryState'], equals('charging'));
      expect(map['batteryStateIndex'], equals(BatteryState.charging.index));
      expect(map['powerSource'], equals('ac'));
      expect(map['powerSourceIndex'], equals(PowerSource.ac.index));
      expect(map['isLowPowerMode'], isFalse);
      expect(map['temperatureCelsius'], equals(28.5));

      final restored = BatteryInfo.fromMap(map);
      expect(restored, equals(sampleBattery));
      expect(restored.hashCode, equals(sampleBattery.hashCode));
    });

    test('handles null battery level safely for desktop devices without batteries', () {
      const desktopPower = BatteryInfo(
        batteryLevel: null,
        batteryState: BatteryState.unknown,
        powerSource: PowerSource.ac,
        isLowPowerMode: false,
        temperatureCelsius: null,
      );

      expect(desktopPower.batteryLevel, isNull);
      expect(desktopPower.batteryFraction, isNull);
      expect(desktopPower.isCharging, isFalse);
      expect(desktopPower.temperatureFahrenheit, isNull);
    });

    test('copyWith creates modified copies correctly', () {
      final modified = sampleBattery.copyWith(
        batteryLevel: 100,
        batteryState: BatteryState.full,
        isLowPowerMode: true,
      );

      expect(modified.batteryLevel, equals(100));
      expect(modified.batteryState, equals(BatteryState.full));
      expect(modified.isLowPowerMode, isTrue);
      expect(modified.powerSource, equals(sampleBattery.powerSource));
      expect(modified.temperatureCelsius, equals(sampleBattery.temperatureCelsius));
    });

    test('toString includes formatted description', () {
      final str = sampleBattery.toString();
      expect(str, contains('85%'));
      expect(str, contains('charging'));
      expect(str, contains('ac'));
      expect(str, contains('28.5°C'));
    });
  });
}
