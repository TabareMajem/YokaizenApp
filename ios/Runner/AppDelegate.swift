import Flutter
import UIKit
import LineSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle URL Schemes
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // First try to handle LINE SDK login callback
    if LoginManager.shared.application(app, open: url) {
      return true
    }
    // Fallback to Flutter plugins (Firebase, Google Sign-in, etc.)
    return super.application(app, open: url, options: options)
  }

  // Handle Universal Links
  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let webpageURL = userActivity.webpageURL,
       LoginManager.shared.application(application, open: webpageURL) {
      return true
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
