import Cocoa
import FlutterMacOS

public class InsideScoopPlugin: NSObject, FlutterPlugin, InsideScoopHostApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = InsideScoopPlugin()
    InsideScoopHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
  }

  func getPlatformVersion() throws -> String? {
    return "macOS " + ProcessInfo.processInfo.operatingSystemVersionString
  }
}
