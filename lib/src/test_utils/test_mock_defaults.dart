// lib/test_utils.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class EasySEOMockPlatformChannels {
  static void useHeadlessDefaults() {
    _mockPathProvider();
    _mockConnectivityPlugin();
  }

  static void _mockConnectivityPlugin({String initialResult = 'wifi'}) {
    // 1. Establish a reference to the exact channel name from the exception
    const MethodChannel channel = MethodChannel('dev.fluttercommunity.plus/connectivity');

    // 2. Set the mock method call handler using the modern TestDefaultBinaryMessenger API
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {

      // 3. Robust route handling based on the channel's API contract
      switch (methodCall.method) {
        case 'check':
        // Returns a string or a list of strings representing the active connection type
        // For connectivity_plus v6+, it typically expects a List<String> or a String matching enum names
          return <String>[initialResult];

        default:
        // Fail gracefully for unexpected methods to maintain test safety
          throw MissingPluginException(
            'No implementation found for method ${methodCall.method} on channel ${channel.name}',
          );
      }
    });
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