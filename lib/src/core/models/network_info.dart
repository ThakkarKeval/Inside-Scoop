import 'package:meta/meta.dart';

/// The overall network connectivity state of the device.
enum NetworkStatus {
  connected,
  disconnected,
  unknown;

  static NetworkStatus fromIndex(int index) {
    if (index >= 0 && index < NetworkStatus.values.length) {
      return NetworkStatus.values[index];
    }
    return NetworkStatus.unknown;
  }
}

/// The physical or virtual network interface transport medium.
enum NetworkConnectionType {
  wifi,
  cellular,
  ethernet,
  bluetooth,
  vpn,
  other,
  none;

  static NetworkConnectionType fromIndex(int index) {
    if (index >= 0 && index < NetworkConnectionType.values.length) {
      return NetworkConnectionType.values[index];
    }
    return NetworkConnectionType.none;
  }
}

/// Device network connectivity metrics, active transmission mediums, and routing flags.
@immutable
class NetworkInfo {
  const NetworkInfo({
    required this.status,
    required this.primaryType,
    this.availableTypes = const [],
    this.isMetered,
    this.isVpnActive,
  });

  /// The active connectivity state of the host device.
  final NetworkStatus status;

  /// The primary transmission connection type currently routing network traffic.
  final NetworkConnectionType primaryType;

  /// All network interface connection types currently accessible and online.
  final List<NetworkConnectionType> availableTypes;

  /// Whether the network connection is subject to data limitations or billing fees (e.g. cellular, mobile hotspot).
  final bool? isMetered;

  /// Whether an active Virtual Private Network (VPN) tunnel is currently established.
  final bool? isVpnActive;

  /// Whether the device has established network connectivity.
  bool get isConnected => status == NetworkStatus.connected;

  /// Creates a [NetworkInfo] instance from a JSON-compatible map.
  factory NetworkInfo.fromMap(Map<String, dynamic> map) {
    final statusIndex = map['statusIndex'] as int? ?? 2;
    final primaryIndex = map['primaryTypeIndex'] as int? ?? 6;
    final typeIndices = (map['availableTypeIndices'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const [];

    return NetworkInfo(
      status: NetworkStatus.fromIndex(statusIndex),
      primaryType: NetworkConnectionType.fromIndex(primaryIndex),
      availableTypes: typeIndices.map(NetworkConnectionType.fromIndex).toList(),
      isMetered: map['isMetered'] as bool?,
      isVpnActive: map['isVpnActive'] as bool?,
    );
  }

  /// Converts this [NetworkInfo] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'statusIndex': status.index,
      'primaryType': primaryType.name,
      'primaryTypeIndex': primaryType.index,
      'availableTypes': availableTypes.map((e) => e.name).toList(),
      'availableTypeIndices': availableTypes.map((e) => e.index).toList(),
      'isMetered': isMetered,
      'isVpnActive': isVpnActive,
    };
  }

  /// Creates a copy of this [NetworkInfo] with optionally replaced fields.
  NetworkInfo copyWith({
    NetworkStatus? status,
    NetworkConnectionType? primaryType,
    List<NetworkConnectionType>? availableTypes,
    bool? isMetered,
    bool? isVpnActive,
  }) {
    return NetworkInfo(
      status: status ?? this.status,
      primaryType: primaryType ?? this.primaryType,
      availableTypes: availableTypes ?? this.availableTypes,
      isMetered: isMetered ?? this.isMetered,
      isVpnActive: isVpnActive ?? this.isVpnActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkInfo &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          primaryType == other.primaryType &&
          _listEquals(availableTypes, other.availableTypes) &&
          isMetered == other.isMetered &&
          isVpnActive == other.isVpnActive;

  @override
  int get hashCode => Object.hash(
    status,
    primaryType,
    Object.hashAll(availableTypes),
    isMetered,
    isVpnActive,
  );

  static bool _listEquals(
    List<NetworkConnectionType> a,
    List<NetworkConnectionType> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    final typesStr = availableTypes.map((e) => e.name).join(', ');
    final meteredStr = isMetered == true ? ', Metered' : '';
    final vpnStr = isVpnActive == true ? ', VPN' : '';
    return 'NetworkInfo(Status: ${status.name}, Primary: ${primaryType.name}, Available: [$typesStr]$meteredStr$vpnStr)';
  }
}
