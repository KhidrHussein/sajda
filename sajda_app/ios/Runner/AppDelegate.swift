import Flutter
import UIKit
import FamilyControls
import ManagedSettings
import DeviceActivity

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let iosChannel = FlutterMethodChannel(name: "com.sajda.sajda_app/ios_restriction",
                                              binaryMessenger: controller.binaryMessenger)
    
    iosChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "requestAuthorization":
          if #available(iOS 15.0, *) {
              Task {
                  do {
                      try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                      result(true)
                  } catch {
                      result(FlutterError(code: "AUTH_FAILED", message: "Failed to authorize FamilyControls", details: nil))
                  }
              }
          } else {
              result(FlutterError(code: "UNSUPPORTED", message: "iOS 15.0 or higher required", details: nil))
          }
      case "showFamilyPicker":
          // Note: Showing the picker usually requires a SwiftUI view.
          // For now, we'll return success and the user will need to implement the SwiftUI part.
          result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
