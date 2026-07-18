import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

import 'test_mock_defaults.dart'; // Pure Dart package, no Flutter dependency

/// Inject the [initialRoute] into the platform channel BEFORE pumpWidget
/// This simulates the browser opening with this URL already in the address bar
void setRouteBeforePumpWidget(WidgetTester tester, String initialRoute) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.navigation, (methodCall) async {
    if (methodCall.method == 'getInitialRoute') {
      return initialRoute;
    }
    return null;
  });
}

/// Step out of fake async zone while waiting for a [condition] to allow
/// real world async operations to finish. Increase [timeout] for long
/// running operations accordingly (e.g. loading lots of db data).
Future<void> waitUntilReady(
    WidgetTester tester,
    bool Function() condition, {
      Duration timeout = const Duration(seconds: 5),
    }) async {
  final end = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(end)) throw Exception('Timeout');

    // 1. Step outside the fake async zone to allow real-time asynchronous operations
    // (like network mocks or engine updates) to catch up.
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

    // 2. Pass a micro-duration to pump().
    // This explicitly tells the Test Widgets Flutter Binding to advance the virtual clock.
    // Advancing the clock forces the engine to flush the microtask queue (your GoRouter redirect
    // provider change) and trigger a layout rebuild frame, without getting stuck in infinite animations.
    await tester.pump(const Duration(milliseconds: 10));
  }
}

/// Waits for a specific [route] to be structurally ready within the [timeout} and handles lifecycle checks.
///
/// The [extraCheck] callback allows to inject custom evaluation rules such as
/// language propagation or global state verifications.
Future<void> waitForRoute(
    String route,
    WidgetTester tester, {
      bool Function()? extraCheck,
      Duration timeout = const Duration(seconds: 5),
    }) async {
  debugPrint('🚀 [TEST] Waiting for: $route');

  await waitUntilReady(tester, () {
    // 1. Core structural DOM check
    final routeExists = find.byKey(ValueKey(route)).evaluate().isNotEmpty;

    // 2. Core package lifecycle readiness check
    final seoReady = EasySEOManager.instance.seoPageIsReady();

    // 3. Evaluate the user-defined hook if it was provided
    if (extraCheck != null) {
      return routeExists && seoReady && extraCheck();
    }

    return routeExists && seoReady;
  }, timeout: timeout);

  debugPrint('🚀 [TEST] DONE waiting for: $route');
}

@isTest
void testSeoWidgets(
    String description,
    Future<void> Function(WidgetTester tester) callback, {
      bool skip = false,
      Timeout? timeout,
    }) {
  // We leverage Flutter's native block under the hood
  testWidgets(
    description,
    (WidgetTester tester) async {
      // AUTOMATED SETUP
      // ignore overflowed error
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      // Set a 4K or Large Desktop resolution
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      final repo = JsonCacheInfoRepository(databaseName: 'libCachedImageData');
      await repo.open();

      try {
        // EXECUTE USER'S ACTUAL TEST CODE
        await callback(tester);
      } finally {
        // AUTOMATED TEARDOWN (Guaranteed to execute even if the test fails)
        await repo.deleteDataFile();
        // Reset error handling state cleanly when this specific test finishes
        FlutterError.onError = originalOnError;
        // reset to default when test finishes (good practice)
        tester.view.resetPhysicalSize;
        tester.view.resetDevicePixelRatio;
      }
    },
    skip: skip,
    timeout: timeout,
  );
}