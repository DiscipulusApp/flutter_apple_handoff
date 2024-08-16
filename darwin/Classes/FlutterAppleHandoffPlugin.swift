import Foundation

#if canImport(UIKit)
  import UIKit
  import Flutter
#elseif canImport(AppKit)
  import AppKit
  import FlutterMacOS
#endif

public class SwiftFlutterAppleHandoffPlugin: NSObject, FlutterPlugin, NSUserActivityDelegate {
  static var channel: FlutterMethodChannel?
  var userActivity: NSUserActivity?

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    channel = FlutterMethodChannel(
      name: "flutter_apple_handoff", binaryMessenger: messenger)
    let instance = SwiftFlutterAppleHandoffPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel!)

    #if os(iOS)
      // This should only be called on iOS, see flutter issue #148233.
      registrar.addApplicationDelegate(instance)
    #endif
  }

  // Handles the activity from the appDelegate
  static public func handleUserActivity(userActivity: NSUserActivity) {
    channel?.invokeMethod(
      "onUserActivity",
      arguments: userActivity.toMap()
    )
  }

  #if os(iOS)
  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([Any]) -> Void
  ) -> Bool {

      if let isHandoff = userActivity.userInfo?["isHandoff"] as? Bool, isHandoff {
        userActivity.resignCurrent()
        userActivity.invalidate()
        SwiftFlutterAppleHandoffPlugin.handleUserActivity(userActivity: userActivity)
        return true
      }
      return false
    }
  #endif

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "update_activity":
      guard let arguments = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
        break
      }

      // Get the current user activity
      #if os(iOS)
        var currentActivity: NSUserActivity?
        if #available(iOS 13.0, *) {
          if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first,
            let rootViewController = window.rootViewController
          {
            currentActivity = rootViewController.userActivity
          }
        } else {
          currentActivity = UIApplication.shared.keyWindow?.rootViewController?.userActivity
        }
      #elseif os(macOS)
        let currentActivity = NSApplication.shared.windows.first?.contentViewController?
          .userActivity
      #endif

      if let activityType = arguments["activityType"] as? String {
        if activityType != currentActivity?.activityType {
          self.userActivity = NSUserActivity(activityType: activityType)
        } else {
          self.userActivity = currentActivity
        }
      } else {
        // Resign current activity if activityType is nil
        currentActivity?.resignCurrent()
        self.userActivity = nil
        result(nil)
        return
      }

      guard let userActivity = self.userActivity else {
        result(
          FlutterError(
            code: "ACTIVITY_ERROR", message: "Failed to create or get NSUserActivity", details: nil)
        )
        return
      }

      userActivity.userInfo = arguments["userInfo"] as? [String: Any]
      userActivity.title = arguments["title"] as? String
      userActivity.isEligibleForHandoff = arguments["isEligibleForHandoff"] as? Bool ?? true
      userActivity.isEligibleForSearch = arguments["isEligibleForSearch"] as? Bool ?? true
      userActivity.isEligibleForPublicIndexing =
        arguments["isEligibleForPublicIndexing"] as? Bool ?? true
      #if os(iOS)
        userActivity.isEligibleForPrediction = arguments["isEligibleForPrediction"] as? Bool ?? true
      #endif
      userActivity.needsSave = true

      // Set the activity to the current activity
      #if os(iOS)
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
          viewController.userActivity = userActivity
          userActivity.becomeCurrent()
          viewController.updateUserActivityState(userActivity)
        }
      #elseif os(macOS)
        if let viewController = NSApplication.shared.windows.first?.contentViewController {
          viewController.userActivity = userActivity
          userActivity.becomeCurrent()
          viewController.updateUserActivityState(userActivity)
        }
      #endif

      result(nil)

      break
    case "current_activity":
      let userActivity: NSUserActivity?
      #if os(iOS)
        userActivity = UIApplication.shared.keyWindow?.rootViewController?.userActivity
      #elseif os(macOS)
        userActivity = NSApplication.shared.windows.first?.contentViewController?.userActivity
      #endif

      result(userActivity?.toMap())

    default:
      result(FlutterMethodNotImplemented)
      break
    }

  }
}

extension NSUserActivity {
  func toMap() -> [String: Any] {
    return [
      "activityType": activityType as Any,
      "userInfo": userInfo as Any,
      "title": title as Any,
      "isEligibleForHandoff": isEligibleForHandoff as Any,
      "isEligibleForSearch": isEligibleForSearch as Any,
      "isEligibleForPublicIndexing": isEligibleForPublicIndexing as Any,
    ]
  }
}
