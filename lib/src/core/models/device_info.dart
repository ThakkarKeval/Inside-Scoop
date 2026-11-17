import 'package:flutter/foundation.dart';

/// Form factor or category of the device.
enum DeviceCategory {
  phone,
  tablet,
  desktop,
  laptop,
  wearable,
  tv,
  unknown;

  /// Resolves a [DeviceCategory] from an ordinal index.
  static DeviceCategory fromIndex(int index) {
    if (index >= 0 && index < DeviceCategory.values.length) {
      return DeviceCategory.values[index];
    }
    return DeviceCategory.unknown;
  }
}

/// Hardware and device metadata.
@immutable
class DeviceInfo {
  const DeviceInfo({
    required this.model,
    required this.manufacturer,
    required this.brand,
    required this.category,
    required this.isPhysicalDevice,
    this.supportedAbis = const <String>[],
  });

  /// Constructs a [DeviceInfo] instance from a serialized Map.
  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      model: map['model'] as String? ?? '',
      manufacturer: map['manufacturer'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      category: DeviceCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => DeviceCategory.unknown,
      ),
      isPhysicalDevice: map['isPhysicalDevice'] as bool? ?? true,
      supportedAbis:
          (map['supportedAbis'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }

  /// Hardware model identifier (e.g. `Pixel 8 Pro`, `iPhone15,3`, `MacBookPro18,1`).
  final String model;

  /// Hardware manufacturer (e.g. `Google`, `Apple`, `Microsoft`, `Dell`).
  final String manufacturer;

  /// Consumer product brand (e.g. `Google`, `Apple`, `ThinkPad`).
  final String brand;

  /// Form factor category of the device.
  final DeviceCategory category;

  /// Whether the host application is running on physical hardware rather than a simulator/emulator.
  final bool isPhysicalDevice;

  /// Binary architectures supported by this device CPU.
  final List<String> supportedAbis;

  /// Returns a copy of this [DeviceInfo] with the given fields replaced.
  DeviceInfo copyWith({
    String? model,
    String? manufacturer,
    String? brand,
    DeviceCategory? category,
    bool? isPhysicalDevice,
    List<String>? supportedAbis,
  }) {
    return DeviceInfo(
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
      supportedAbis: supportedAbis ?? this.supportedAbis,
    );
  }

  /// Converts this [DeviceInfo] to a map structure.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'model': model,
      'manufacturer': manufacturer,
      'brand': brand,
      'category': category.name,
      'isPhysicalDevice': isPhysicalDevice,
      'supportedAbis': supportedAbis,
    };
  }

  /// Converts this [DeviceInfo] to a JSON-compatible map.
  Map<String, dynamic> toJson() => toMap();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          manufacturer == other.manufacturer &&
          brand == other.brand &&
          category == other.category &&
          isPhysicalDevice == other.isPhysicalDevice &&
          listEquals(supportedAbis, other.supportedAbis);

  @override
  int get hashCode => Object.hash(
    model,
    manufacturer,
    brand,
    category,
    isPhysicalDevice,
    Object.hashAll(supportedAbis),
  );

  @override
  String toString() =>
      'DeviceInfo(model: $model, manufacturer: $manufacturer, brand: $brand, category: $category, isPhysicalDevice: $isPhysicalDevice, supportedAbis: $supportedAbis)';
}
