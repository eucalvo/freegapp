import UIKit
import Flutter
import GoogleMaps
import flutter_dotenv

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    do {
      let env = try Dotenv.load()
      let apiKey = env["GOOGLE_MAPS_API_KEY_IOS"]
      GMSServices.provideAPIKey(apiKey)
    } catch {
      print("Failed to load environment variables")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
