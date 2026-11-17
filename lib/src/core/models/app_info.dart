import 'package:meta/meta.dart';

/// Comprehensive metadata for the running host application.
@immutable
class AppInfo {
  const AppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.buildSignature,
    this.installerStore,
  });

  /// Creates an [AppInfo] instance from a serialized Map.
  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      appName: map['appName'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
      version: map['version'] as String? ?? '',
      buildNumber: map['buildNumber'] as String? ?? '',
      buildSignature: map['buildSignature'] as String?,
      installerStore: map['installerStore'] as String?,
    );
  }

  /// The human-readable display name of the application.
  final String appName;

  /// The unique package identifier (e.g. `com.example.app` or bundle ID).
  final String packageName;

  /// The user-facing release version string (e.g. `1.0.0`).
  final String version;

  /// The machine or internal build number (e.g. `42` or `1`).
  final String buildNumber;

  /// The SHA-256 signing certificate checksum or fingerprint if available.
  final String? buildSignature;

  /// The source store or package installer if available (e.g. `com.android.vending`, `TestFlight`).
  final String? installerStore;

  /// Returns a copy of this [AppInfo] with the given fields replaced.
  AppInfo copyWith({
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
    String? buildSignature,
    String? installerStore,
  }) {
    return AppInfo(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      buildSignature: buildSignature ?? this.buildSignature,
      installerStore: installerStore ?? this.installerStore,
    );
  }

  /// Converts this [AppInfo] to a map structure.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
      if (buildSignature != null) 'buildSignature': buildSignature,
      if (installerStore != null) 'installerStore': installerStore,
    };
  }

  /// Converts this [AppInfo] to a JSON-compatible map.
  Map<String, dynamic> toJson() => toMap();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfo &&
          runtimeType == other.runtimeType &&
          appName == other.appName &&
          packageName == other.packageName &&
          version == other.version &&
          buildNumber == other.buildNumber &&
          buildSignature == other.buildSignature &&
          installerStore == other.installerStore;

  @override
  int get hashCode => Object.hash(
    appName,
    packageName,
    version,
    buildNumber,
    buildSignature,
    installerStore,
  );

  @override
  String toString() =>
      'AppInfo(appName: $appName, packageName: $packageName, version: $version, buildNumber: $buildNumber, buildSignature: $buildSignature, installerStore: $installerStore)';
}
