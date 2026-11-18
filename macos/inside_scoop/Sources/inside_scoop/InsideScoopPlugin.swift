import Cocoa
import FlutterMacOS
import IOKit.ps
import Metal
import Network

public class InsideScoopPlugin: NSObject, FlutterPlugin, InsideScoopHostApi, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var pathMonitor: NWPathMonitor?
  private let monitorQueue = DispatchQueue(label: "com.cavernlabs.inside_scoop.network_monitor")

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = InsideScoopPlugin()
    InsideScoopHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
    let eventChannel = FlutterEventChannel(name: "com.cavernlabs.inside_scoop/network_events", binaryMessenger: registrar.messenger)
    eventChannel.setStreamHandler(instance)
  }

  func getPlatformVersion() throws -> String? {
    return "macOS " + ProcessInfo.processInfo.operatingSystemVersionString
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

    let isAppStore = bundle.appStoreReceiptURL?.lastPathComponent == "_MASReceipt"
    let installerStore = isAppStore ? "MacAppStore" : "Standalone"

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
    #endif

    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

    return PlatformOsInfo(
      name: "macOS",
      version: versionString,
      buildNumber: buildNumber,
      architecture: arch,
      kernelVersion: kernelVersion
    )
  }

  func getDeviceInfo() throws -> PlatformDeviceInfo {
    var size = 0
    sysctlbyname("hw.model", nil, &size, nil, 0)
    var modelBytes = [CChar](repeating: 0, count: size)
    sysctlbyname("hw.model", &modelBytes, &size, nil, 0)
    let model = String(cString: modelBytes)

    let isLaptop = model.lowercased().contains("book")
    let categoryIndex: Int64 = isLaptop ? 3 : 2 // 3: laptop, 2: desktop

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
      isPhysicalDevice: true,
      supportedAbis: supportedAbis
    )
  }

  func getCpuInfo() throws -> PlatformCpuInfo {
    var brandSize = 0
    sysctlbyname("machdep.cpu.brand_string", nil, &brandSize, nil, 0)
    var brandName: String? = nil
    if brandSize > 0 {
      var brandBytes = [CChar](repeating: 0, count: brandSize)
      sysctlbyname("machdep.cpu.brand_string", &brandBytes, &brandSize, nil, 0)
      let brandStr = String(cString: brandBytes).trimmingCharacters(in: .whitespacesAndNewlines)
      if !brandStr.isEmpty {
        brandName = brandStr
      }
    }

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
    #endif

    return PlatformCpuInfo(
      architecture: arch,
      modelName: brandName,
      physicalCores: physicalCores > 0 ? Int64(physicalCores) : nil,
      logicalCores: Int64(logicalCores),
      maxClockSpeedMhz: maxClockSpeedMhz,
      systemUtilization: nil,
      processUtilization: nil
    )
  }

  func getMemoryInfo() throws -> PlatformMemoryInfo {
    let totalMem = Int64(ProcessInfo.processInfo.physicalMemory)
    var pageSize: vm_size_t = 0
    host_page_size(mach_host_self(), &pageSize)

    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
    var vmStats = vm_statistics64_data_t()
    let kernReturn = withUnsafeMutablePointer(to: &vmStats) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
      }
    }

    var availableMem: Int64 = totalMem / 2
    if kernReturn == KERN_SUCCESS && pageSize > 0 {
      let freeBytes = Int64(vmStats.free_count) * Int64(pageSize)
      let inactiveBytes = Int64(vmStats.inactive_count) * Int64(pageSize)
      availableMem = freeBytes + inactiveBytes
    }

    var taskInfo = mach_task_basic_info()
    var taskCount = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
    let taskReturn = withUnsafeMutablePointer(to: &taskInfo) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(taskCount)) {
        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &taskCount)
      }
    }

    let residentBytes: Int64? = taskReturn == KERN_SUCCESS ? Int64(taskInfo.resident_size) : nil
    let virtualBytes: Int64? = taskReturn == KERN_SUCCESS ? Int64(taskInfo.virtual_size) : nil

    return PlatformMemoryInfo(
      totalPhysicalBytes: totalMem,
      availablePhysicalBytes: availableMem,
      processResidentBytes: residentBytes,
      processVirtualBytes: virtualBytes,
      isLowMemory: availableMem < (totalMem / 10)
    )
  }

  func getStorageInfo() throws -> PlatformStorageInfo {
    let rootURL = URL(fileURLWithPath: "/")
    var totalBytes: Int64 = 256 * 1024 * 1024 * 1024
    var availBytes: Int64 = 128 * 1024 * 1024 * 1024

    if let values = try? rootURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey, .volumeAvailableCapacityForImportantUsageKey]) {
      if let total = values.volumeTotalCapacity {
        totalBytes = Int64(total)
      }
      if let availImportant = values.volumeAvailableCapacityForImportantUsage {
        availBytes = availImportant
      } else if let avail = values.volumeAvailableCapacity {
        availBytes = Int64(avail)
      }
    }

    return PlatformStorageInfo(
      totalBytes: totalBytes,
      availableBytes: availBytes,
      appStorageBytes: nil,
      isRemovable: false
    )
  }

  func getGpuInfo() throws -> PlatformGpuInfo {
    let devices = MTLCopyAllDevices()
    let device = devices.first ?? MTLCreateSystemDefaultDevice()

    guard let dev = device else {
      return PlatformGpuInfo(
        vendor: "Apple",
        renderer: "Apple GPU",
        apiFamily: "Metal",
        apiVersion: "Metal 3",
        totalVramBytes: nil,
        isUnifiedMemory: true
      )
    }

    let name = dev.name
    let hasUnifiedMemory = dev.hasUnifiedMemory
    let maxWorkingSet = Int64(dev.recommendedMaxWorkingSetSize)

    let vendor = name.lowercased().contains("intel") ? "Intel"
      : (name.lowercased().contains("amd") || name.lowercased().contains("radeon")) ? "AMD"
      : (name.lowercased().contains("nvidia") || name.lowercased().contains("geforce")) ? "NVIDIA"
      : "Apple"

    return PlatformGpuInfo(
      vendor: vendor,
      renderer: name,
      apiFamily: "Metal",
      apiVersion: "Metal 3",
      totalVramBytes: maxWorkingSet > 0 ? maxWorkingSet : nil,
      isUnifiedMemory: hasUnifiedMemory
    )
  }

  func getBatteryInfo() throws -> PlatformBatteryInfo {
    var batteryLevel: Int64? = nil
    var batteryStateIndex: Int64 = 3 // unknown
    var powerSourceIndex: Int64 = 4 // unknown

    let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
    let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as [CFTypeRef]

    for ps in sources {
      if let desc = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as? [String: Any] {
        if let current = desc[kIOPSCurrentCapacityKey] as? Int,
           let max = desc[kIOPSMaxCapacityKey] as? Int, max > 0 {
          batteryLevel = Int64((Double(current) / Double(max)) * 100.0)
        }

        let isCharging = desc[kIOPSIsChargingKey] as? Bool ?? false
        let isCharged = desc[kIOPSIsChargedKey] as? Bool ?? false
        let powerState = desc[kIOPSPowerSourceStateKey] as? String ?? ""

        if powerState == kIOPSACPowerValue {
          powerSourceIndex = 1 // AC
          if isCharged {
            batteryStateIndex = 2 // full
          } else if isCharging {
            batteryStateIndex = 0 // charging
          } else {
            batteryStateIndex = 2 // full
          }
        } else if powerState == kIOPSBatteryPowerValue {
          powerSourceIndex = 0 // battery
          batteryStateIndex = 1 // discharging
        }
        break
      }
    }

    var isLowPower: Bool? = nil
    if #available(macOS 12.0, *) {
      isLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    return PlatformBatteryInfo(
      batteryLevel: batteryLevel,
      batteryStateIndex: batteryStateIndex,
      powerSourceIndex: powerSourceIndex,
      isLowPowerMode: isLowPower,
      temperatureCelsius: nil
    )
  }

  func getNetworkInfo() throws -> PlatformNetworkInfo {
    let monitor = NWPathMonitor()
    let semaphore = DispatchSemaphore(value: 0)
    var currentPath: NWPath?
    monitor.pathUpdateHandler = { path in
      currentPath = path
      semaphore.signal()
    }
    monitor.start(queue: monitorQueue)
    _ = semaphore.wait(timeout: .now() + 0.1)
    monitor.cancel()

    return buildPlatformNetworkInfo(path: currentPath)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    self.pathMonitor = NWPathMonitor()
    self.pathMonitor?.pathUpdateHandler = { [weak self] path in
      self?.sendNetworkUpdate(path: path)
    }
    self.pathMonitor?.start(queue: monitorQueue)
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.pathMonitor?.cancel()
    self.pathMonitor = nil
    self.eventSink = nil
    return nil
  }

  private func buildPlatformNetworkInfo(path: NWPath?) -> PlatformNetworkInfo {
    guard let path = path else {
      return PlatformNetworkInfo(
        statusIndex: 2, // unknown
        primaryTypeIndex: 6, // none
        availableTypeIndices: [],
        isMetered: nil,
        isVpnActive: nil
      )
    }

    let isConnected = (path.status == .satisfied)
    var available: [Int64?] = []
    var primary: Int64 = 6 // none

    if path.usesInterfaceType(.wifi) {
      available.append(0) // wifi
    }
    if path.usesInterfaceType(.cellular) {
      available.append(1) // cellular
    }
    if path.usesInterfaceType(.wiredEthernet) {
      available.append(2) // ethernet
    }

    if path.usesInterfaceType(.wiredEthernet) {
      primary = 2
    } else if path.usesInterfaceType(.wifi) {
      primary = 0
    } else if path.usesInterfaceType(.cellular) {
      primary = 1
    } else if isConnected {
      primary = 5 // other
    } else {
      primary = 6 // none
    }

    let isMetered = path.isExpensive

    return PlatformNetworkInfo(
      statusIndex: isConnected ? 0 : 1,
      primaryTypeIndex: primary,
      availableTypeIndices: available,
      isMetered: isMetered,
      isVpnActive: false
    )
  }

  private func sendNetworkUpdate(path: NWPath) {
    let info = buildPlatformNetworkInfo(path: path)
    let map: [String: Any] = [
      "statusIndex": info.statusIndex,
      "primaryTypeIndex": info.primaryTypeIndex,
      "availableTypeIndices": info.availableTypeIndices.compactMap { $0 },
      "isMetered": info.isMetered as Any,
      "isVpnActive": info.isVpnActive as Any
    ]
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(map)
    }
  }
}
