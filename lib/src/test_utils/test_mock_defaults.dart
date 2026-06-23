// lib/test_utils.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class EasySEOMockPlatformChannels {
  static void useHeadlessDefaults() {
    _mockPathProvider();
  }

  static void _mockPathProvider() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getApplicationSupportDirectory': // Maps to getApplicationSupportPath()
            return '.';
          case 'getTemporaryDirectory':
            return '.';
          case 'getApplicationDocumentsDirectory':
            return '.';
          default:
            return null;
        }
      },
    );
  }
}