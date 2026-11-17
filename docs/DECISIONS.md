# Architecture Decision Records (ADRs): inside_scoop

## ADR 001: Strict Package Independence
- **Status**: Accepted
- **Context**: Existing Flutter packages (`package_info_plus`, `device_info_plus`, `battery_plus`, `system_info_plus`, etc.) wrap system information. Depending on them introduces dependency bloat, transitive conflicts, and violates the core mission of an independent SDK.
- **Decision**: Implement all system data extraction directly via native platform APIs (Kotlin on Android, Swift on iOS/macOS, C++ on Windows/Linux, and `dart:js_interop`/`package:web` on Web).
- **Consequences**: Complete control over API stability, data validation, zero third-party wrapper overhead, and license safety.

---

## ADR 002: Type-Safe IPC with Pigeon
- **Status**: Accepted
- **Context**: Standard `MethodChannel` uses string-based method identifiers and dynamically typed dictionaries/maps, which are error-prone and lack compile-time contract enforcement.
- **Decision**: Use Flutter's official `pigeon` tool to generate strongly typed interfaces across Dart, Kotlin, Swift, and C++.
- **Consequences**: Compile-time type safety across host platforms, automatic serializer generation, and elimination of manual JSON/Map parsing boilerplate.

---

## ADR 003: Sealed Result Types (`ScoopResult<T>`)
- **Status**: Accepted
- **Context**: Hardware and OS capabilities vary significantly between desktop, mobile, and web. Returning `null`, dummy fallback values, or throwing unexpected platform exceptions leads to fragile client applications.
- **Decision**: Use Dart 3 sealed classes (`ScoopResult<T>` with `ScoopAvailable<T>` and `ScoopUnavailable<T>`).
- **Consequences**: Developers are forced by compiler exhaustiveness to handle unavailability reasons explicitly, preventing crashes and misrepresenting fake hardware capabilities.

---

## ADR 004: Modern Web Interop with `package:web` and `dart:js_interop`
- **Status**: Accepted
- **Context**: `dart:html` is deprecated in Dart 3 and incompatible with WebAssembly (WASM).
- **Decision**: All Web implementations use `package:web` and `dart:js_interop`.
- **Consequences**: Full forward compatibility with Dart WASM compilation and strict isolation from `dart:io`.
