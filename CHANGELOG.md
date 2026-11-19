## 1.1.0

* **Corrected Android Memory Metrics**: Replaced JVM heap reporting with authentic Resident Set Size (RSS) and Virtual Memory (VmSize) read directly from `/proc/self/status`.
* **Proportional Set Size & Process Breakdown**: Introduced `ProcessMemoryInfo` exposing `residentSetBytes`, `virtualBytes`, `totalPssBytes` (via `Debug.getMemoryInfo`), and separated JVM/ART heap metrics.
* **Eliminated Fabricated Fallbacks**: Removed hardcoded fallback constants across Android (4GB RAM, 64GB storage defaults) and Web (1.0.0 app version, 4GB RAM, 10GB storage defaults, and static GPU renderer).
* **Metric Quality & Provenance**: Introduced `MetricQuality` (`measured`, `estimated`, `inferred`, `unavailable`) and `SystemMetric<T>` wrapper with `.toMetric()` on `ScoopResult<T>`.
* **Diagnostic Comparison API**: Introduced `DiagnosticDiff` and `DiagnosticReport.diff()` to track deltas in memory, storage, battery, and environmental states (network, charging, low memory pressure) over time.
* **Configurable Health Alerts**: Added `HealthAlert`, `HealthThresholds`, and `MonitoringService.watchHealthAlerts()` stream for proactive warnings.
* **Monitoring Robustness**: Added internal re-entrancy protection to prevent concurrent sampling operations when hardware queries are slow.
* **Repository Visibility**: Updated repository and issue tracker URLs to match GitHub casing (`Inside-Scoop`).

## 1.0.0

* Initial stable release of `inside_scoop`.
* Full support for Android, iOS, macOS, Windows, Linux, and Web.
* Zero external system-wrapper dependencies.
* Hardware & OS subsystems:
  * Application metadata (`AppInfo`)
  * Device and operating system metadata (`DeviceInfo`, `OsInfo`)
  * Runtime capability queries (`CapabilitiesService`)
  * CPU specifications and cores (`CpuInfo`)
  * Physical RAM and app memory metrics (`MemoryInfo`)
  * Storage volume metrics (`StorageInfo`)
  * GPU renderer and graphics APIs (`GpuInfo`)
  * Battery and power metrics (`BatteryInfo`)
  * Network connectivity and live observables (`NetworkInfo`)
  * Consolidated real-time sampling engine (`MonitoringService`)
  * Privacy-aware diagnostic reporting and Markdown generator (`DiagnosticsService`)

