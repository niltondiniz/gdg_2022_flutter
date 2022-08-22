import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAveyyNwnS0PMy3TRLLWraxeyqMC8cnxU8")
    GeneratedPluginRegistrant.register(with: self)    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
