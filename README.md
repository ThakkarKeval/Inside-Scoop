# inside_scoop

An independent, zero-dependency 6-platform Flutter System Information and Hardware Diagnostics SDK.

Supports **Android**, **iOS**, **macOS**, **Windows**, **Linux**, and **Web** using direct native platform APIs.

---

## Features

- **App Metadata**: Package ID, version, build number, installer store, signing certificate SHA-256.
- **Device & OS**: Model, manufacturer, brand, categories, physical device detection, kernel and OS build.
- **Capabilities Discovery**: Dynamic feature availability and sandbox detection.
- **CPU Specifications**: Architecture, physical and logical core topology, vendor model name, clock frequencies.
- **Memory (RAM)**: Total, available, and used system RAM, process resident memory, low memory pressure alerts.
- **Storage Volumes**: Disk total and free capacity, app cache and storage consumption.
- **GPU & Graphics**: Renderer name, vendor, graphics API family (Metal, Vulkan, DirectX, WebGL), VRAM.
- **Battery & Power**: Charge level, power source, charging state, low power mode, temperature.
- **Network Connectivity**: Connection state, primary interfaces (Wi-Fi, cellular, ethernet, VPN), metered status, live observable stream.
- **Real-Time Monitoring**: Consolidated lifecycle-aware periodic sampling engine (`MonitoringService`).
- **System Diagnostics**: One-shot system audit with automated PII redaction and Markdown generation.

---

## Quickstart

Add `inside_scoop` to your `pubspec.yaml`:

```yaml
dependencies:
  inside_scoop: ^1.0.0
```

### Basic Usage

You can use the convenient shared singleton `InsideScoop.instance` or create a new `InsideScoop()` instance:

```dart
import 'package:inside_scoop/inside_scoop.dart';

void main() async {
  final scoop = InsideScoop.instance;

  // 1. Application Information
  final appResult = await scoop.app.getInfo();
  if (appResult case ScoopAvailable(:final value)) {
    print('App: ${value.appName} (${value.packageName})');
    print('Version: ${value.version}+${value.buildNumber}');
    print('Store: ${value.installerStore}');
  }

  // 2. Device & OS Metadata
  final deviceResult = await scoop.device.getInfo();
  final osResult = await scoop.os.getInfo();
  if (deviceResult case ScoopAvailable(:final value)) {
    print('Device: ${value.manufacturer} ${value.model} (${value.category.name})');
    print('Physical device: ${value.isPhysicalDevice}');
  }
  if (osResult case ScoopAvailable(:final value)) {
    print('OS: ${value.name} ${value.version} (${value.architecture})');
  }

  // 3. Processor / CPU
  final cpuResult = await scoop.cpu.getInfo();
  if (cpuResult case ScoopAvailable(:final value)) {
    print('CPU: ${value.modelName ?? "Unknown"} (${value.logicalCores} cores)');
  }

  // 4. Memory (RAM)
  final memoryResult = await scoop.memory.getInfo();
  if (memoryResult case ScoopAvailable(:final value)) {
    print('RAM: ${value.availablePhysicalMb} MB / ${value.totalPhysicalMb} MB available');
    print('Memory usage: ${value.usagePercentage.toStringAsFixed(1)}%');
  }

  // 5. Storage
  final storageResult = await scoop.storage.getInfo();
  if (storageResult case ScoopAvailable(:final value)) {
    print('Storage: ${value.availableGb.toStringAsFixed(1)} GB / ${value.totalGb.toStringAsFixed(1)} GB free');
  }

  // 6. GPU & Graphics
  final gpuResult = await scoop.gpu.getInfo();
  if (gpuResult case ScoopAvailable(:final value)) {
    print('GPU: ${value.renderer} (${value.vendor})');
    print('Graphics API: ${value.apiFamily} ${value.apiVersion ?? ""}');
  }

  // 7. Battery & Power
  final batteryResult = await scoop.battery.getInfo();
  if (batteryResult case ScoopAvailable(:final value)) {
    print('Battery: ${value.batteryLevel}% (${value.batteryState.name})');
    print('Power source: ${value.powerSource.name}');
  }

  // 8. Network Snapshot & Live Observable Stream
  final networkResult = await scoop.network.getInfo();
  if (networkResult case ScoopAvailable(:final value)) {
    print('Network: ${value.primaryType.name} (connected: ${value.isConnected})');
  }

  // Subscribe to live connectivity updates
  final subscription = scoop.network.watch().listen((network) {
    print('Live connection change: ${network.primaryType.name} (online: ${network.isConnected})');
  });

  // 9. Real-time Lifecycle-Aware System Monitoring
  final monitoringSub = scoop.monitoring
      .startMonitoring(
        config: const MonitoringConfig(
          interval: Duration(seconds: 2),
          sampleCpu: true,
          sampleMemory: true,
          sampleBattery: true,
          sampleNetwork: true,
        ),
      )
      .listen((snapshot) {
        print('Snapshot at ${snapshot.timestamp}: RAM free = ${snapshot.memory?.availablePhysicalMb} MB');
      });

  // 10. Comprehensive Diagnostics & Redacted Markdown Export
  final report = await scoop.diagnostics.generateReport(
    options: const DiagnosticOptions(redactSensitiveData: true),
  );
  print(report.toMarkdown());
}
```

---

## Result Handling: `ScoopResult<T>`

All one-shot query APIs return a type-safe sealed class `ScoopResult<T>` to gracefully handle platform permissions and restrictions without unhandled crashes:

```dart
final result = await InsideScoop.instance.battery.getInfo();

switch (result) {
  case ScoopAvailable(:final value):
    print('Battery level: ${value.batteryLevel}%');
  case ScoopUnavailable(:final reason, :final message):
    print('Battery data unavailable: $reason ($message)');
}
```



