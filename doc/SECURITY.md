# Security and Privacy Policy: inside_scoop

## 1. Privacy Principles

`inside_scoop` adheres strictly to privacy-first SDK design:
- **No Fingerprinting**: The SDK does not read or compute hardware fingerprint identifiers (`SSAID`/Android ID, IMEI, MAC addresses, hardware serials, `IOPlatformUUID`).
- **No Privileged Permissions**: The plugin never requires privileged permissions (e.g. `READ_PRIVILEGED_PHONE_STATE`). All operations execute within standard user or app sandboxes.
- **No Network Telemetry**: Zero background network transmissions, telemetry, analytics, or automated error uploads.

---

## 2. Platform Sandboxing Compliance

- **Android**: Only public `Build`, `PackageManager`, `ActivityManager`, and system services. Strict handling of Android 10+ non-resettable identifier restrictions.
- **iOS & macOS**: Public Apple APIs only (`UIDevice`, `ProcessInfo`, `sysctl`, `MTLCreateSystemDefaultDevice`). No private frameworks or unauthorized entitlements.
- **Windows**: All Win32 calls run in standard user token context. No administrative elevation required.
- **Linux**: Reads only public virtual filesystems (`/proc`, `/sys`). No shell spawning (`sh -c`) to prevent command injection risks.
- **Web**: Explicit unavailable handling when browser privacy flags (e.g. Firefox fingerprint protection) restrict hardware queries.

---

## 3. Diagnostic Redaction

When exporting diagnostic reports:
- Hostnames, usernames, local IP addresses, and exact user file paths are redacted by default unless explicitly configured by the developer.
