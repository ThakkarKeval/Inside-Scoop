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
}
