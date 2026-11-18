import 'package:meta/meta.dart';

/// The charging and discharge status of the device battery.
enum BatteryState {
  charging,
  discharging,
  full,
  unknown;

  static BatteryState fromIndex(int index) {
    if (index >= 0 && index < BatteryState.values.length) {
      return BatteryState.values[index];
    }
    return BatteryState.unknown;
  }
}

/// The external power connection source supplying electricity to the device.
enum PowerSource {
  battery,
  ac,
  usb,
  wireless,
  unknown;

  static PowerSource fromIndex(int index) {
    if (index >= 0 && index < PowerSource.values.length) {
      return PowerSource.values[index];
    }
    return PowerSource.unknown;
  }
}

/// Device battery metrics, power source connections, and OS power management state.
@immutable
class BatteryInfo {
  const BatteryInfo({
    this.batteryLevel,
    required this.batteryState,
    required this.powerSource,
    this.isLowPowerMode,
    this.temperatureCelsius,
    this.chargeWatts,
  });

  /// The current battery level as a percentage integer from 0 to 100, or `null` if no battery is present.
  final int? batteryLevel;

  /// The active charging or discharging state of the battery.
  final BatteryState batteryState;

  /// The active external electrical source supplying power to the system.
  final PowerSource powerSource;

  /// Whether the operating system battery saver or low power mode is currently active.
  final bool? isLowPowerMode;

  /// The current internal battery temperature in degrees Celsius (°C), if exposed by the hardware.
  final double? temperatureCelsius;

  /// The real-time electrical power charging rate in Watts (W), if supported by the hardware/OS.
  final double? chargeWatts;

  /// Whether the battery is actively receiving electrical power.
  bool get isCharging => batteryState == BatteryState.charging;

  /// The battery level represented as a normalized floating point value from 0.0 to 1.0.
  double? get batteryFraction =>
      batteryLevel != null ? batteryLevel! / 100.0 : null;

  /// The battery temperature converted to degrees Fahrenheit (°F), if available.
  double? get temperatureFahrenheit =>
      temperatureCelsius != null
          ? (temperatureCelsius! * 9 / 5) + 32
          : null;

  /// Creates a [BatteryInfo] instance from a JSON-compatible map.
  factory BatteryInfo.fromMap(Map<String, dynamic> map) {
    final stateIndex = map['batteryStateIndex'] as int? ?? 3;
    final sourceIndex = map['powerSourceIndex'] as int? ?? 4;
    return BatteryInfo(
      batteryLevel: (map['batteryLevel'] as num?)?.toInt(),
      batteryState: BatteryState.fromIndex(stateIndex),
      powerSource: PowerSource.fromIndex(sourceIndex),
      isLowPowerMode: map['isLowPowerMode'] as bool?,
      temperatureCelsius: (map['temperatureCelsius'] as num?)?.toDouble(),
      chargeWatts: (map['chargeWatts'] as num?)?.toDouble(),
    );
  }

  /// Converts this [BatteryInfo] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'batteryLevel': batteryLevel,
      'batteryState': batteryState.name,
      'batteryStateIndex': batteryState.index,
      'powerSource': powerSource.name,
      'powerSourceIndex': powerSource.index,
      'isLowPowerMode': isLowPowerMode,
      'temperatureCelsius': temperatureCelsius,
      'chargeWatts': chargeWatts,
    };
  }

  /// Creates a copy of this [BatteryInfo] with optionally replaced fields.
  BatteryInfo copyWith({
    int? batteryLevel,
    BatteryState? batteryState,
    PowerSource? powerSource,
    bool? isLowPowerMode,
    double? temperatureCelsius,
    double? chargeWatts,
  }) {
    return BatteryInfo(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryState: batteryState ?? this.batteryState,
      powerSource: powerSource ?? this.powerSource,
      isLowPowerMode: isLowPowerMode ?? this.isLowPowerMode,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      chargeWatts: chargeWatts ?? this.chargeWatts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatteryInfo &&
          runtimeType == other.runtimeType &&
          batteryLevel == other.batteryLevel &&
          batteryState == other.batteryState &&
          powerSource == other.powerSource &&
          isLowPowerMode == other.isLowPowerMode &&
          temperatureCelsius == other.temperatureCelsius &&
          chargeWatts == other.chargeWatts;

  @override
  int get hashCode => Object.hash(
    batteryLevel,
    batteryState,
    powerSource,
    isLowPowerMode,
    temperatureCelsius,
    chargeWatts,
  );

  @override
  String toString() {
    final levelStr = batteryLevel != null ? '$batteryLevel%' : 'No Battery';
    final tempStr =
        temperatureCelsius != null
            ? ', Temp: ${temperatureCelsius!.toStringAsFixed(1)}°C'
            : '';
    final powerSaveStr =
        isLowPowerMode == true ? ', Low Power Mode' : '';
    return 'BatteryInfo(Level: $levelStr, State: ${batteryState.name}, Power: ${powerSource.name}$tempStr$powerSaveStr)';
  }
}
