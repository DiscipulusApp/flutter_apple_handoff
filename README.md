# Flutter Apple Handoff Plugin

The `flutter_apple_handoff` plugin provides a simple API for integrating Apple's Handoff functionality into your Flutter applications. Handoff allows users to start an activity on one device and continue it on another, seamlessly. This plugin supports iOS and macOS platforms.

## Features

- Start and update `NSUserActivity` to enable Handoff.
- Handle Handoff activities from other devices.
- Easily update activity state and user information.
  
## Getting Started

### Installation

To use this plugin, add `flutter_apple_handoff` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_apple_handoff:
    git:
      url: https://github.com/HarryDeKat/flutter_apple_handoff.git
```

Then run `flutter pub get` to fetch the plugin.

### macOS Setup

**Note:** As of the current version, automatic handling of Handoff activities on macOS is not fully supported by flutter (see [#148233](https://github.com/flutter/flutter/issues/148233)). You need to manually add the following code to your macOS `AppDelegate`:

```swift
import Cocoa
import FlutterMacOS
import flutter_apple_handoff

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: NSApplication, continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void
    ) -> Bool {
        
        // Handoff
        if let isHandoff = userActivity.userInfo?["isHandoff"] as? Bool, isHandoff {
            // This is a handoff activity
            userActivity.resignCurrent()
            userActivity.invalidate()
            SwiftFlutterAppleHandoffPlugin.handleUserActivity(userActivity: userActivity)
            return true
        }
        
        return false
    }
}
```

This code ensures that Handoff activities are properly handled on macOS. Without it, the plugin will not be able to intercept Handoff activities on macOS devices.

### Platform Integration

#### iOS

In your `ios/Runner/Info.plist`, ensure that you add the following:

```xml
<key>NSUserActivityTypes</key>
<array>
  <string>com.yourcompany.yourapp.activity</string>
</array>
```

This registers the types of activities your app supports. Replace `com.yourcompany.yourapp.activity` with the appropriate activity type for your app.

#### macOS

In your `macos/Runner/Info.plist`, add:

```xml
<key>NSUserActivityTypes</key>
<array>
  <string>com.yourcompany.yourapp.activity</string>
</array>
```

Similarly, replace `com.yourcompany.yourapp.activity` with the relevant activity type.

### Usage

Here's how you can use the plugin in your Flutter app:

#### Initialize and Update Activity

To begin using Handoff, you'll need to create and update `NSUserActivity` instances. This allows the app to share the state across devices.

```dart
import 'package:flutter_apple_handoff/flutter_apple_handoff.dart';

Future<void> initiateHandoff() async {
  NSUserActivity activity = NSUserActivity(
    // This needs to be the same as in your NSUserActivityTypes plist entry.
    activityType: 'com.yourcompany.yourapp.activity',
    title: 'Reading Article: Flutter Handoff',
    userInfo: {
      'articleId': '12345',
      'position': 'Page 3',
    },
  );

  await activity.becomeCurrent();
  // This is the same as
  // await FlutterAppleHandoff.updateActivity(activity);
}
```

#### Handling Handoff

To handle Handoff from another device, you can set up a callback to be notified when an activity is continued:

```dart
void main() {
  FlutterAppleHandoff.onActivityChanged = (NSUserActivity activity) {
    print('Continued activity: ${activity.title}');
    // Handle the continued activity, e.g., navigate to the corresponding screen.
  };
  
  runApp(MyApp());
}
```

This callback will be triggered whenever a Handoff activity is detected, allowing you to seamlessly continue the user's progress.

#### Retrieving Current Activity

You can retrieve the current activity at any time:

```dart
void fetchCurrentActivity() async {
  NSUserActivity? activity = await FlutterAppleHandoff.getCurrentActivity;

  if (activity != null) {
    print('Current activity: ${activity.title}');
    // Handle current activity state
  } else {
    print('No active Handoff activity.');
  }
}
```

## Contributions

Contributions are welcome! Please submit issues and pull requests to the [GitHub repository](https://github.com/HarryDeKat/flutter_apple_handoff).

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/HarryDeKat/flutter_apple_handoff/blob/main/LICENSE) file for details.