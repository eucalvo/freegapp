import UIKit
import Flutter
import GoogleMaps
import dotenv

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let dotenv = Dotenv()
    dotenv.load()

    let apiKey = dotenv["GOOGLE_MAPS_API_KEY_IOS"]
    GMSServices.provideAPIKey(apiKey!)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
