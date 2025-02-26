import Flutter
import UIKit
import AppTrackingTransparency // Import the ATT framework

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Request App Tracking Transparency permission
    requestTrackingPermission()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func requestTrackingPermission() {
    if #available(iOS 14, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Delay to ensure it's not too disruptive
        ATTrackingManager.requestTrackingAuthorization { status in
          switch status {
          case .authorized:
            print("Tracking authorized")
          case .denied, .notDetermined, .restricted:
            print("Tracking not authorized or undecided")
          @unknown default:
            print("Unknown authorization status")
          }
        }
      }
    }
  }
}
