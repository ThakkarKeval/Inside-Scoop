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

```dart
import 'package:inside_scoop/inside_scoop.dart';

void main() async {
  // Application Information
  final app = await InsideScoop.app.getInfo();
  if (app case ScoopAvailable(:final value)) {
    print('Running ${value.appName} v${value.version}');
  }

  // Device & OS Metadata
  final device = await InsideScoop.device.getInfo();
  final os = await InsideScoop.os.getInfo();

  // Hardware Specs
  final cpu = await InsideScoop.cpu.getInfo();
  final memory = await InsideScoop.memory.getInfo();
  final storage = await InsideScoop.storage.getInfo();
  final gpu = await InsideScoop.gpu.getInfo();
  final battery = await InsideScoop.battery.getInfo();

  // Network Snapshot & Observable Stream
  final network = await InsideScoop.network.getInfo();
  InsideScoop.network.watch().listen((status) {
    print('Connectivity changed: ${status.isConnected}');
  });

  // Diagnostic Report
  final report = await InsideScoop.diagnostics.generateReport();
  print(report.toMarkdown());
}
```


