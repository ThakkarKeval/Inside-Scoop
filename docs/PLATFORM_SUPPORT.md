# Platform Support Matrix: inside_scoop

## 1. Supported Platforms & Environments

| Platform | Minimum Target | Preferred Language / Tooling | Sandbox & Security Context |
|---|---|---|---|
| **Android** | Android 7.0 (API 24)+ | Kotlin + Android SDK | Android Application Sandbox |
| **iOS** | iOS 13.0+ | Swift + Public Apple Frameworks | iOS App Sandbox |
| **macOS** | macOS 10.15+ (Catalina) | Swift + Darwin / IOKit | macOS App Sandbox |
| **Windows** | Windows 10 (Build 1809)+ | C++17 + Win32 APIs | Standard User Token |
| **Linux** | GLIBC 2.27+ / Modern distros | C++17 + POSIX / `/proc` / `/sys` | Non-root Standard Process |
| **Web** | Chrome 90+, Safari 14+, Firefox 88+ | Dart JS Interop + `package:web` | Browser Security Sandbox |

---

## 2. Planned Feature Matrix by Platform

| Feature Domain | Android | iOS | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **App Info** | Full | Full | Full | Full | Full | Partial (Domain/Title) |
| **Device & OS** | Full | Full | Full | Full | Full | Partial (Platform/UA) |
| **Capabilities** | Full | Full | Full | Full | Full | Full |
| **CPU Info** | Full | Full | Full | Full | Full | Partial (Logical cores) |
| **Memory (RAM)** | Full | Full | Full | Full | Full | Partial (DeviceMemory) |
| **Storage** | Full | Full | Full | Full | Full | Storage Quota |
| **GPU Info** | Context | Metal | Metal/IOKit | DXGI | GL/DRM | WebGL Context |
| **Battery & Power** | Full | Full | Full | Full | Full | Browser Battery API |
| **Network Info** | Full | NWPath | NWPath | IP Helper | POSIX | Online/Connection |
| **Monitoring** | Event/Poll | Event/Poll | Event/Poll | Event/Poll | Poll | Event |
| **Diagnostics** | Full | Full | Full | Full | Full | Full |

---

## 3. Implemented Feature Status

### Phase 1: Application Information (`AppInfo`)
- **Android**: `PackageManager` querying label, package name, `versionName`, `longVersionCode`, `getInstallSourceInfo`, and certificate SHA-256 fingerprint.
- **iOS**: `Bundle.main` (`CFBundleDisplayName`, `CFBundleShortVersionString`, `CFBundleVersion`, receipt analysis).
- **macOS**: `Bundle.main` (name, bundle ID, version strings, `_MASReceipt` check).
- **Windows**: Win32 (`GetModuleFileNameW`, `GetFileVersionInfoW`, `VerQueryValueW`).
- **Linux**: POSIX binary location / desktop specification parser fallback.
- **Web**: `web.document.title`, `web.window.location.host`.

### Phase 2: Device & Operating System Metadata (`OsInfo`, `DeviceInfo`)
- **Android**: `Build` (`MODEL`, `MANUFACTURER`, `BRAND`, `VERSION.RELEASE`, `DISPLAY`, `SUPPORTED_ABIS`), emulator heuristic detection, and `UiModeManager`/smallest-width screen category resolution.
- **iOS**: `UIDevice.current` (system name, version, idiom), `sysctlbyname` (`hw.machine`, `kern.osversion`, `kern.version`), `#if targetEnvironment(simulator)`.
- **macOS**: `ProcessInfo.processInfo`, `sysctlbyname` (`hw.model`, `kern.osversion`, `kern.version`), MacBook laptop vs desktop classification.
- **Windows**: `RtlGetVersion` via `ntdll.dll`, `GetNativeSystemInfo` architecture, and `GetComputerNameW`.
- **Linux**: POSIX and system release inspection fallbacks.
- **Web**: `package:web` reading `navigator.userAgent`, `navigator.platform`, `navigator.maxTouchPoints`, and screen resolution.

### Phase 3: Capability Detection (`CapabilitiesService`)
- Dynamic runtime capability inspection mapping each `ScoopFeature` to `ScoopCapabilityState` (`supported`, `unsupported`, `requiresPermission`, `restricted`) with contextual descriptions.
- Accurately models Android SELinux sandboxing (`cpuUtilization` restricted on Android 8.0+) and permission requirements (`networkInfo` requires `ACCESS_NETWORK_STATE`).
- Accurately models browser sandbox restrictions (unsupported CPU utilization and battery status, restricted hardware specifications, memory, and network info).

### Phase 4: CPU Information (`CpuInfo`)
- **Android**: `Build.SUPPORTED_ABIS`, `Build.SOC_MODEL` (API 31+) / `/proc/cpuinfo` / `Build.HARDWARE` model name, `Runtime.getRuntime().availableProcessors()` logical cores, physical core topology via `/sys/devices/system/cpu/cpu*/topology/core_id`, and clock speed via `/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`.
- **iOS**: `sysctlbyname("hw.machine")`, `hw.logicalcpu`, `hw.physicalcpu`, and `hw.cpufrequency`.
- **macOS**: `sysctlbyname("machdep.cpu.brand_string")`, `hw.logicalcpu`, `hw.physicalcpu`, and `hw.cpufrequency`.
- **Windows**: Win32 `GetNativeSystemInfo`, `GetLogicalProcessorInformationEx` for physical cores, registry `CentralProcessor\0` for processor model name and clock speed.
- **Web**: `window.navigator.hardwareConcurrency` logical cores, architecture inference via `userAgent`, with unsupported fields properly set to `null` to respect browser security boundaries.
