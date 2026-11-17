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
