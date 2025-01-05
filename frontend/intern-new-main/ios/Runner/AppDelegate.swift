import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // This ensures that the Flutter plugins are registered properly.
    GeneratedPluginRegistrant.register(with: self)
    
    // Additional setup after launching, if needed
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}