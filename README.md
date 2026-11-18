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

---

## Detailed Platform Parameter Support Matrix

Below is the comprehensive field-by-field availability breakdown across all 6 target platforms. A checkmark (✅) denotes full native availability, (⚠️) denotes restricted/approximate support depending on sandbox policy or permissions, and (❌) denotes hardware or OS-level unavailability.

### 1. Application Information (`AppInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `appName` | ✅ (`ApplicationInfo`) | ✅ (`CFBundleDisplayName`) | ✅ (`CFBundleName`) | ✅ (`VerQueryValueW`) | ✅ (`desktop/proc`) | ✅ (`document.title`) |
| `packageName` | ✅ (`packageName`) | ✅ (`bundleIdentifier`) | ✅ (`bundleIdentifier`) | ✅ (`ModuleFileName`) | ✅ (`Executable`) | ✅ (`window.location.host`) |
| `version` | ✅ (`versionName`) | ✅ (`CFBundleShortVersion`) | ✅ (`CFBundleShortVersion`) | ✅ (`ProductVersion`) | ✅ (`Version`) | ✅ (`1.0.0`) |
| `buildNumber` | ✅ (`longVersionCode`) | ✅ (`CFBundleVersion`) | ✅ (`CFBundleVersion`) | ✅ (`FileVersion`) | ✅ (`Build`) | ✅ (`1`) |
| `installerStore` | ✅ (`InstallSourceInfo`) | ✅ (`StoreReceipt`) | ✅ (`MASReceipt`) | ✅ (`Win32/MSIX`) | ❌ | ❌ |
| `buildSignature` | ✅ (SHA-256 cert) | ❌ | ❌ | ❌ | ❌ | ❌ |

---

### 2. Operating System (`OsInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `name` | ✅ (`Android`) | ✅ (`iOS`) | ✅ (`macOS`) | ✅ (`Windows`) | ✅ (`Linux distro`) | ✅ (`Web (platform)`) |
| `version` | ✅ (`Build.VERSION.RELEASE`) | ✅ (`UIDevice.systemVersion`) | ✅ (`ProcessInfo`) | ✅ (`RtlGetVersion`) | ✅ (`os-release`) | ✅ (`Browser`) |
| `buildNumber` | ✅ (`Build.DISPLAY`) | ✅ (`kern.osversion`) | ✅ (`kern.osversion`) | ✅ (`dwBuildNumber`) | ✅ (`uname -r`) | ✅ (`UserAgent`) |
| `architecture` | ✅ (`SUPPORTED_ABIS[0]`) | ✅ (`arm64`) | ✅ (`arm64/x86_64`) | ✅ (`GetNativeSystemInfo`) | ✅ (`uname -m`) | ✅ (`wasm/js`) |
| `kernelVersion` | ✅ (`uname.release`) | ✅ (`kern.version`) | ✅ (`kern.version`) | ❌ | ✅ (`uname -r`) | ❌ |

---

### 3. Device Hardware (`DeviceInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `model` | ✅ (`Build.MODEL`) | ✅ (`hw.machine`) | ✅ (`hw.model`) | ✅ (`ComputerName`) | ✅ (`sys_vendor/product`) | ✅ (`Browser Client`) |
| `manufacturer` | ✅ (`Build.MANUFACTURER`) | ✅ (`Apple`) | ✅ (`Apple`) | ✅ (`Win32/OEM`) | ✅ (`DMI sys_vendor`) | ✅ (`Web Client`) |
| `brand` | ✅ (`Build.BRAND`) | ✅ (`Apple`) | ✅ (`Apple`) | ✅ (`Microsoft/OEM`) | ✅ (`Vendor`) | ✅ (`Web`) |
| `category` | ✅ (`Phone/Tablet/TV/Auto`) | ✅ (`Phone/Pad`) | ✅ (`Laptop/Desktop`) | ✅ (`Desktop/Laptop`) | ✅ (`Desktop/Server`) | ✅ (`Touch/Screen width`) |
| `isPhysicalDevice` | ✅ (Heuristic & Fingerprint) | ✅ (`!TARGET_IPHONE_SIMULATOR`) | ✅ (`true`) | ✅ (`true`) | ✅ (`true`) | ✅ (`true`) |
| `supportedAbis` | ✅ (`Build.SUPPORTED_ABIS`) | ✅ (`arm64`) | ✅ (`arm64/x86_64`) | ✅ (`Native arch`) | ✅ (`uname -m`) | ✅ (`wasm, js`) |

---

### 4. Processor / CPU (`CpuInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `architecture` | ✅ (`SUPPORTED_ABIS[0]`) | ✅ (`arm64`) | ✅ (`arm64/x86_64`) | ✅ (`wProcessorArchitecture`) | ✅ (`uname -m`) | ⚠️ (Inferred from UA) |
| `modelName` | ✅ (`SOC_MODEL / cpuinfo`) | ❌ (Sandbox protected) | ✅ (`machdep.cpu.brand`) | ✅ (`ProcessorNameString`) | ✅ (`model name`) | ❌ (W3C privacy) |
| `logicalCores` | ✅ (`availableProcessors`) | ✅ (`hw.logicalcpu`) | ✅ (`hw.logicalcpu`) | ✅ (`dwNumberOfProcessors`) | ✅ (`nproc`) | ✅ (`hardwareConcurrency`) |
| `physicalCores` | ✅ (`sys/devices/cpu/topology`) | ✅ (`hw.physicalcpu`) | ✅ (`hw.physicalcpu`) | ✅ (`LogicalProcessorInfoEx`) | ✅ (`cpu cores`) | ❌ (W3C privacy) |
| `maxClockSpeedMhz` | ✅ (`cpuinfo_max_freq`) | ❌ (Sandbox protected) | ❌ (Apple Silicon dynamic) | ✅ (`~MHz registry`) | ✅ (`cpu MHz`) | ❌ (W3C privacy) |

---

### 5. Memory / RAM (`MemoryInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `totalPhysicalBytes` | ✅ (`ActivityManager/meminfo`) | ✅ (`ProcessInfo.physicalMemory`)| ✅ (`ProcessInfo.physicalMemory`)| ✅ (`GlobalMemoryStatusEx`) | ✅ (`MemTotal`) | ⚠️ (`navigator.deviceMemory`) |
| `availablePhysicalBytes`| ✅ (`ActivityManager.availMem`) | ✅ (`host_statistics64`) | ✅ (`host_statistics64`) | ✅ (`ullAvailPhys`) | ✅ (`MemAvailable`) | ⚠️ (Approximate) |
| `usedPhysicalBytes` | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ⚠️ (Approximate) |
| `usagePercentage` | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ⚠️ (Approximate) |
| `isLowMemory` | ✅ (`ActivityManager.lowMemory`) | ⚠️ (Memory pressure) | ⚠️ (Memory pressure) | ✅ (`MemoryLoad > 90%`) | ⚠️ (`MemAvailable < 10%`) | ❌ |
| `processResidentBytes` | ✅ (`Runtime.totalMemory()`) | ✅ (`mach_task_basic_info`) | ✅ (`mach_task_basic_info`) | ✅ (`WorkingSetSize`) | ✅ (`VmRSS`) | ❌ |
| `processVirtualBytes` | ❌ | ❌ | ❌ | ✅ (`PagefileUsage`) | ✅ (`VmSize`) | ❌ |

---

### 6. Storage Volume (`StorageInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `totalBytes` | ✅ (`StatFs.totalBytes`) | ✅ (`volumeTotalCapacityKey`) | ✅ (`volumeTotalCapacityKey`) | ✅ (`GetDiskFreeSpaceExW`) | ✅ (`statvfs.f_blocks`) | ✅ (`storage.estimate().quota`) |
| `availableBytes` | ✅ (`StatFs.availableBytes`) | ✅ (`volumeAvailableCapacityKey`) | ✅ (`volumeAvailableCapacityKey`)| ✅ (`lpFreeBytesAvailable`) | ✅ (`statvfs.f_bavail`) | ✅ (`quota - usage`) |
| `usedBytes` | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) |
| `usagePercentage` | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) | ✅ (Calculated) |
| `isRemovable` | ✅ (`Environment.isExternalStorageRemovable`) | ❌ (`false`) | ❌ (`false`) | ❌ (`false`) | ❌ | ❌ (`false`) |
| `appStorageBytes` | ✅ (`filesDir + cacheDir`) | ❌ (Sandbox protected) | ❌ | ❌ | ❌ | ✅ (`estimate().usage`) |

---

### 7. Graphics Processing Unit (`GpuInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `vendor` | ✅ (`GLES20.GL_VENDOR`) | ✅ (`Apple`) | ✅ (`Apple / Intel / AMD`) | ✅ (`DXGI Adapter Desc`) | ✅ (`OpenGL / DRM`) | ✅ (`WebGL Context / Vendor`) |
| `renderer` | ✅ (`GLES20.GL_RENDERER`)| ✅ (`MTLDevice.name`) | ✅ (`MTLDevice.name`) | ✅ (`Description string`) | ✅ (`GL_RENDERER`) | ✅ (`WebGL Renderer`) |
| `apiFamily` | ✅ (`OpenGL ES / Vulkan`) | ✅ (`Metal`) | ✅ (`Metal`) | ✅ (`DirectX 3D (DXGI)`) | ✅ (`OpenGL / Vulkan`) | ✅ (`WebGL`) |
| `apiVersion` | ✅ (`GL_VERSION`) | ✅ (`Metal Feature Set`) | ✅ (`Metal Feature Set`) | ❌ | ✅ (`GL_VERSION`) | ✅ (`2.0`) |
| `totalVramBytes` | ❌ (Unified system RAM) | ⚠️ (`maxWorkingSetSize`) | ⚠️ (`maxWorkingSetSize`) | ✅ (`DedicatedVideoMemory`) | ⚠️ (If dedicated) | ❌ |
| `isUnifiedMemory` | ✅ (`true` on mobile) | ✅ (`hasUnifiedMemory`) | ✅ (`hasUnifiedMemory`) | ❌ (`false` on dGPU) | ⚠️ (Arch-dependent) | ❌ |

---

### 8. Battery & Power (`BatteryInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `batteryLevel` | ✅ (`BatteryManager.EXTRA_LEVEL`)| ✅ (`UIDevice.batteryLevel`) | ✅ (`IOPMPowerSource`) | ✅ (`SYSTEM_POWER_STATUS`) | ✅ (`/sys/class/power_supply`) | ❌ (W3C privacy) |
| `batteryState` | ✅ (`charging/discharging/full`)| ✅ (`UIDeviceBatteryState`) | ✅ (`IsCharging / IsCharged`)| ✅ (`BatteryFlag`) | ✅ (`status`) | ❌ (W3C privacy) |
| `powerSource` | ✅ (`AC, USB, Wireless, Battery`)| ✅ (`UIDevice`) | ✅ (`AC / Battery Power`) | ✅ (`ACLineStatus`) | ✅ (`type`) | ❌ (W3C privacy) |
| `chargeWatts` | ✅ (Real-time $\mu A \times mV$) | ❌ (Hardware restricted) | ❌ | ❌ | ⚠️ (`power_now`) | ❌ |
| `isLowPowerMode` | ✅ (`PowerManager.isPowerSaveMode`)| ✅ (`isLowPowerModeEnabled`)| ✅ (`isLowPowerModeEnabled`)| ❌ | ❌ | ❌ |
| `temperatureCelsius`| ✅ (`EXTRA_TEMPERATURE / 10`) | ❌ (Sandbox protected) | ❌ | ❌ | ⚠️ (`temp`) | ❌ |

---

### 9. Network Connectivity (`NetworkInfo`)

| Parameter | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `status` | ✅ (`connected/disconnected`) | ✅ (`NWPath.status`) | ✅ (`NWPath.status`) | ✅ (`InternetGetConnectedState`)| ✅ (`getifaddrs`) | ✅ (`navigator.onLine`) |
| `primaryType` | ✅ (`Wi-Fi, Cellular, Ethernet`) | ✅ (`wifi, cellular, ethernet`) | ✅ (`wifi, wiredEthernet`)| ✅ (`LAN, Modem`) | ✅ (`Interface check`) | ⚠️ (`online / other`) |
| `availableTypes` | ✅ (Active transports list) | ✅ (Active interfaces list)| ✅ (Active interfaces list)| ✅ (Interface list) | ✅ (Active interfaces) | ⚠️ (Active connection) |
| `isMetered` | ✅ (`NET_CAPABILITY_NOT_METERED`)| ✅ (`NWPath.isExpensive`) | ✅ (`NWPath.isExpensive`) | ❌ | ❌ | ⚠️ (`connection.saveData`) |
| `isVpnActive` | ✅ (`TRANSPORT_VPN`) | ❌ | ❌ | ❌ | ⚠️ (`tun/tap`) | ❌ |
| `watch()` Stream | ✅ (`NetworkCallback`) | ✅ (`NWPathMonitor`) | ✅ (`NWPathMonitor`) | ⚠️ (Polled stream) | ⚠️ (Polled stream) | ✅ (`online/offline` DOM) |

---

### 10. Real-time Monitoring & Diagnostics (`MonitoringService`, `DiagnosticsService`)

| Feature | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Lifecycle-aware continuous sampling | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Configurable sample cadence & domain filters | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Consolidated point-in-time snapshot | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Privacy-redacted diagnostic audit | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| GitHub-flavored Markdown generator | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |




