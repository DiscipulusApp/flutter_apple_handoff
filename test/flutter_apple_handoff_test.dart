import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_apple_handoff/flutter_apple_handoff.dart';
import 'package:flutter_apple_handoff/flutter_apple_handoff_platform_interface.dart';
import 'package:flutter_apple_handoff/flutter_apple_handoff_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAppleHandoffPlatform
    with MockPlatformInterfaceMixin
    implements FlutterAppleHandoffPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterAppleHandoffPlatform initialPlatform = FlutterAppleHandoffPlatform.instance;

  test('$MethodChannelFlutterAppleHandoff is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterAppleHandoff>());
  });

  test('getPlatformVersion', () async {
    FlutterAppleHandoff flutterAppleHandoffPlugin = FlutterAppleHandoff();
    MockFlutterAppleHandoffPlatform fakePlatform = MockFlutterAppleHandoffPlatform();
    FlutterAppleHandoffPlatform.instance = fakePlatform;

    expect(await flutterAppleHandoffPlugin.getPlatformVersion(), '42');
  });
}
