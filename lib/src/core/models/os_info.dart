import 'package:meta/meta.dart';

/// Operating system metadata for the host platform.
@immutable
class OsInfo {
  const OsInfo({
    required this.name,
    required this.version,
    required this.buildNumber,
    required this.architecture,
    this.kernelVersion,
  });

  /// Constructs an [OsInfo] instance from a serialized Map.
  factory OsInfo.fromMap(Map<String, dynamic> map) {
    return OsInfo(
      name: map['name'] as String? ?? '',
      version: map['version'] as String? ?? '',
      buildNumber: map['buildNumber'] as String? ?? '',
      architecture: map['architecture'] as String? ?? '',
      kernelVersion: map['kernelVersion'] as String?,
    );
  }

  /// The name of the operating system (e.g. Android, iOS, macOS, Windows, Linux, Web).
  final String name;

  /// The human-readable version string of the operating system.
  final String version;

  /// The internal build or release identifier of the operating system.
  final String buildNumber;

  /// The instruction set architecture of the operating system (e.g. arm64, x86_64).
  final String architecture;

  /// The kernel version identifier if available.
  final String? kernelVersion;

  /// Returns a copy of this [OsInfo] with the given fields replaced.
  OsInfo copyWith({
    String? name,
    String? version,
    String? buildNumber,
    String? architecture,
    String? kernelVersion,
  }) {
    return OsInfo(
      name: name ?? this.name,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      architecture: architecture ?? this.architecture,
      kernelVersion: kernelVersion ?? this.kernelVersion,
    );
  }

  /// Converts this [OsInfo] to a map structure.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'version': version,
      'buildNumber': buildNumber,
      'architecture': architecture,
      if (kernelVersion != null) 'kernelVersion': kernelVersion,
    };
  }

  /// Converts this [OsInfo] to a JSON-compatible map.
  Map<String, dynamic> toJson() => toMap();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OsInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          version == other.version &&
          buildNumber == other.buildNumber &&
          architecture == other.architecture &&
          kernelVersion == other.kernelVersion;

  @override
  int get hashCode =>
      Object.hash(name, version, buildNumber, architecture, kernelVersion);

  @override
  String toString() =>
      'OsInfo(name: $name, version: $version, buildNumber: $buildNumber, architecture: $architecture, kernelVersion: $kernelVersion)';
}
