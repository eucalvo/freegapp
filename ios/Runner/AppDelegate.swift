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

    let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY_IOS"]
    GMSServices.provideAPIKey(apiKey!)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
