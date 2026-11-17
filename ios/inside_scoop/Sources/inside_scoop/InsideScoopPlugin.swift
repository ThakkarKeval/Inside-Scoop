import Flutter
import UIKit

public class InsideScoopPlugin: NSObject, FlutterPlugin, InsideScoopHostApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = InsideScoopPlugin()
    InsideScoopHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
  }

  func getPlatformVersion() throws -> String? {
    return "iOS " + UIDevice.current.systemVersion
  }

  func getAppInfo() throws -> PlatformAppInfo {
    let bundle = Bundle.main
    let info = bundle.infoDictionary
    let appName = info?["CFBundleDisplayName"] as? String
      ?? info?["CFBundleName"] as? String
      ?? ""
    let packageName = bundle.bundleIdentifier ?? ""
    let version = info?["CFBundleShortVersionString"] as? String ?? ""
    let buildNumber = info?["CFBundleVersion"] as? String ?? ""

    let isTestFlight = bundle.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    let installerStore = isTestFlight ? "TestFlight" : (bundle.appStoreReceiptURL != nil ? "AppStore" : nil)

    return PlatformAppInfo(
      appName: appName,
      packageName: packageName,
      version: version,
      buildNumber: buildNumber,
      buildSignature: nil,
      installerStore: installerStore
    )
  }

  func getOsInfo() throws -> PlatformOsInfo {
    var size = 0
    sysctlbyname("kern.osversion", nil, &size, nil, 0)
    var buildBytes = [CChar](repeating: 0, count: size)
    sysctlbyname("kern.osversion", &buildBytes, &size, nil, 0)
    let buildNumber = String(cString: buildBytes)

    var kernelSize = 0
    sysctlbyname("kern.version", nil, &kernelSize, nil, 0)
    var kernelBytes = [CChar](repeating: 0, count: kernelSize)
    sysctlbyname("kern.version", &kernelBytes, &kernelSize, nil, 0)
    let kernelVersion = String(cString: kernelBytes)

    var arch = "unknown"
    #if arch(arm64)
    arch = "arm64"
    #elseif arch(x86_64)
    arch = "x86_64"
    #elseif arch(arm)
    arch = "arm"
    #endif

    return PlatformOsInfo(
      name: "iOS",
      version: UIDevice.current.systemVersion,
      buildNumber: buildNumber,
      architecture: arch,
      kernelVersion: kernelVersion
    )
  }

  func getDeviceInfo() throws -> PlatformDeviceInfo {
    var size = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machineBytes = [CChar](repeating: 0, count: size)
    sysctlbyname("hw.machine", &machineBytes, &size, nil, 0)
    let model = String(cString: machineBytes)

    var categoryIndex: Int64 = 0
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      categoryIndex = 0
    case .pad:
      categoryIndex = 1
    case .tv:
      categoryIndex = 5
    default:
      categoryIndex = 6
    }

    var isPhysicalDevice = true
    #if targetEnvironment(simulator)
    isPhysicalDevice = false
    #endif

    var supportedAbis: [String?] = []
    #if arch(arm64)
    supportedAbis = ["arm64", "arm64e"]
    #elseif arch(x86_64)
    supportedAbis = ["x86_64"]
    #endif

    return PlatformDeviceInfo(
      model: model,
      manufacturer: "Apple",
      brand: "Apple",
      categoryIndex: categoryIndex,
      isPhysicalDevice: isPhysicalDevice,
      supportedAbis: supportedAbis
    )
  }

  func getCpuInfo() throws -> PlatformCpuInfo {
    var size = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machineBytes = [CChar](repeating: 0, count: size)
    sysctlbyname("hw.machine", &machineBytes, &size, nil, 0)
    let machine = String(cString: machineBytes)

    var logicalCores: Int32 = 0
    var logicalSize = MemoryLayout<Int32>.size
    sysctlbyname("hw.logicalcpu", &logicalCores, &logicalSize, nil, 0)
    if logicalCores <= 0 {
      logicalCores = Int32(ProcessInfo.processInfo.activeProcessorCount)
    }

    var physicalCores: Int32 = 0
    var physicalSize = MemoryLayout<Int32>.size
    sysctlbyname("hw.physicalcpu", &physicalCores, &physicalSize, nil, 0)

    var freq: Int64 = 0
    var freqSize = MemoryLayout<Int64>.size
    sysctlbyname("hw.cpufrequency", &freq, &freqSize, nil, 0)
    let maxClockSpeedMhz: Int64? = freq > 0 ? freq / 1_000_000 : nil

    var arch = "unknown"
    #if arch(arm64)
    arch = "arm64"
    #elseif arch(x86_64)
    arch = "x86_64"
    #elseif arch(arm)
    arch = "arm"
    #endif

    return PlatformCpuInfo(
      architecture: arch,
      modelName: machine.isEmpty ? nil : "Apple Silicon (\(machine))",
      physicalCores: physicalCores > 0 ? Int64(physicalCores) : nil,
      logicalCores: Int64(logicalCores),
      maxClockSpeedMhz: maxClockSpeedMhz,
      systemUtilization: nil,
      processUtilization: nil
    )
  }
}
