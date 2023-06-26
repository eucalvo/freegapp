import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY_IOS"] {
      GMSServices.provideAPIKey(apiKey)
    } else {
      fatalError("Google Maps API key not found. Please set the GOOGLE_MAPS_API_KEY_IOS environment variable.")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
