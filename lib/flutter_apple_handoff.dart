import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_apple_handoff/Classes/user_activity.dart';

export 'package:flutter_apple_handoff/Classes/user_activity.dart';

class FlutterAppleHandoff {
  FlutterAppleHandoff._();

  static final MethodChannel _channel = MethodChannel('flutter_apple_handoff')
    ..setMethodCallHandler(_callBack);

  // Callback for when an activity is launched
  static Future<void> _callBack(MethodCall call) async {
    if (call.method == "onUserActivity") {
      // New activity
      onActivityChanged?.call(
          NSUserActivity.fromMap(call.arguments.cast<String, dynamic>())!);
    }
  }

  /// Updates the current user activity.
  ///
  /// This **automatically** adds the the entry `{"isHandoff": true}` to the
  /// userinfo map. This is done so we can differentiate between handoff and
  /// other types of activities such as Spotlight entries. This can be disabled
  /// by setting `addHandoffIndicator` to false.
  static Future<void> updateActivity(
    NSUserActivity? activity, {
    bool addHandoffIndicator = true,
  }) async {
    if (kDebugMode)
      print(activity != null
          ? "Updating activity to \"${activity?.title}\""
          : "Clearing activity");

    // Add indicator
    if (addHandoffIndicator) {
      activity?.userInfo ??= <String, dynamic>{};
      activity?.userInfo!.addAll({"isHandoff": true});
    }

    await _channel.invokeMethod('update_activity', activity?.toMap() ?? {});
  }

  /// Returns the current activity if there is one
  static Future<NSUserActivity?> get getCurrentActivity async {
    var currentAct = await _channel.invokeMethod('current_activity');
    return currentAct != null
        ? NSUserActivity.fromMap(currentAct!.cast<String, dynamic>())
        : null;
  }

  static Future<void> Function(NSUserActivity activity)? onActivityChanged;
}
