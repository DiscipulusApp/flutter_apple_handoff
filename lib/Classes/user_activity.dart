import 'package:flutter_apple_handoff/flutter_apple_handoff.dart';

/// Apple's NSUserActivity. This class is to be used with Handoff.
class NSUserActivity {
  /// The activity type.
  ///
  /// This string is used to uniquely identify the type of activity.
  String activityType;

  /// A dictionary that contains app-specific state information needed to continue an activity on another device.
  ///
  /// You can use this dictionary to store any relevant information about the user’s activity.
  Map<String, dynamic>? userInfo;

  /// The title of the user activity.
  ///
  /// This string is used by the system to display the activity to the user.
  String? title;

  /// A Boolean value indicating whether the activity should be continued on another device.
  ///
  /// Set this property to true to make the activity eligible for Handoff.
  bool isEligibleForHandoff = true;

  /// A Boolean value that indicates whether the activity should be indexed by the system’s search feature.
  ///
  /// Set this property to true to make the activity eligible for search indexing.
  bool isEligibleForSearch = true;

  /// A Boolean value that indicates whether the activity should be added to the public index.
  ///
  /// Set this property to true to make the activity eligible for public indexing.
  bool isEligibleForPublicIndexing = true;

  /// A Boolean value that determines whether Siri can suggest the user activity as a shortcut to the user.
  /// **iOS only**, this property will be ignored on macOS.
  bool isEligibleForPrediction = true;

  NSUserActivity({
    required this.activityType,
    this.userInfo,
    this.title,
    this.isEligibleForHandoff = true,
    this.isEligibleForSearch = true,
    this.isEligibleForPublicIndexing = true,
    this.isEligibleForPrediction = true,
  });

  /// Updates the user activity.
  ///
  /// This method marks the user activity as needing an update.
  Future<void> becomeCurrent() async =>
      await FlutterAppleHandoff.updateActivity(this);

  Map<String, dynamic> toMap() {
    return {
      'activityType': activityType,
      'userInfo': userInfo,
      // 'userInfoEntries': userInfoEntries,
      'title': title,
      'isEligibleForHandoff': isEligibleForHandoff,
      'isEligibleForSearch': isEligibleForSearch,
      'isEligibleForPublicIndexing': isEligibleForPublicIndexing,
      'isEligibleForPrediction': isEligibleForPrediction
    }..removeWhere((key, value) => value == null);
  }

  static NSUserActivity? fromMap(Map<String, dynamic> map) {
    return map['activityType'] != null
        ? NSUserActivity(
            activityType: map['activityType'],
            userInfo: Map<String, dynamic>.from(map['userInfo'] ?? {}),
            title: map['title'],
            isEligibleForHandoff: map['isEligibleForHandoff'] ?? true,
            isEligibleForSearch: map['isEligibleForSearch'] ?? true,
            isEligibleForPublicIndexing:
                map['isEligibleForPublicIndexing'] ?? true,
            isEligibleForPrediction: map['isEligibleForPrediction'] ?? true,
          )
        : null;
  }
}
