import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_easy_seo_example/app.dart' show App;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 1. Initialize essential plugin mocks (required for booting in native test env)
    EasySEOMockPlatformChannels.useHeadlessDefaultMocks();
  });

  testSeoWidgets('SEO generation and sitemap', (tester) async {
    // start app
    await tester.pumpWidget(App(initialLocale: 'de'));

    // disable calls to onGenerate
    EasySEOManager.instance.disableOnGenerate.value = true;
    EasySEOManager.instance.enableInteractiveMode.value = false;

    // define the routes to generate
    var routes = EasySEOManager.instance.getAllRoutes();
    final initialRoute = '/de';
    routes.removeWhere((e) => e == '/' || e == initialRoute);

    // simulate browser opening initial route
    setRouteBeforePumpWidget(tester, initialRoute);


    // wait for initial route and generate
    await visitRouteAndGenerate(initialRoute, null, tester);

    // get GoRouter
    final router = tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig as GoRouter;

    // visit all static routes
    for (final route in routes) {
      await visitRouteAndGenerate(route, router, tester);
    }

    // get gathered dynamic routes and visit all dynamic routes
    var gatheredRoutes = EasySEOManager.instance.getAllRoutes(gatheredOnly: true);
    for (final route in gatheredRoutes) {
      await visitRouteAndGenerate(route, router, tester);
    }

    // generate and send sitemap
    await generateAndSendSitemap(tester);
  });
}

Future<void> visitRouteAndGenerate(String route, GoRouter? router, WidgetTester tester) async {
  debugPrint('🚀 [TEST] Navigating to: $route');
  if (router != null) {
    router.go(route);
  }

  // make sure the EasySEO for that route is there and the route is ready
  await waitForRoute(route, tester, extraCheck: () => true /*  */);
  // generate seo mock and send to server endpoint
  await generateAndSend(tester, isRoot: router == null);
  // Fast-forward to clear the cache manager's cleanup timer
  await tester.pump(const Duration(seconds: 30));

  debugPrint('✅ [TEST] Completed wait for: $route');
}

Future<void> generateAndSend(WidgetTester tester, {bool isRoot = false}) async {
  // We use runAsync to allow the real world http socket to move
  await tester.runAsync(() async {
    var result = await EasySEOManager.instance.generateActive();
    String message = "";
    switch (result) {
      case SeoSuccess(:final fullHtml, :final currentLanguage, :final path):
        await sendAndWait(fullHtml, currentLanguage, path);
        if (isRoot) {
          await sendAndWait(fullHtml, currentLanguage, "");
        }
        message = "✅ Successfully synced SEO for path $path";
        break;
      case SeoSkipped(:final reason):
        message = "ℹ️ Skipped: $reason";
        break;
      case SeoFailure(:final error):
        message = "❌ Failed: $error";
        break;
      default:
        message = "⚠️ Unknown state";
    }
    debugPrint(message);
  });
}

String _exampleRoot() {
  final cwd = Directory.current.path;
  for (final dir in [cwd, p.join(cwd, 'example'), p.dirname(cwd)]) {
    final pubspec = File(p.join(dir, 'pubspec.yaml'));
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('name: flutter_easy_seo_example')) {
      return dir;
    }
  }
  return cwd;
}

Future<void> sendAndWait(String fullHtml, String currentLanguage, String path) async {
  /// ALTERNATIVE: Use a service to send the generated data to a REST endpoint
  /// that stores the files in your web server so they can be delivered
  /// to search bots.
  // debugPrint('🚀 [TEST] Sending generated SEO HTML to server for path: $path');
  // await SEOSyncService().sendGeneratedData(
  //   html: fullHtml,
  //   language: currentLanguage,
  //   path: '$path/index',
  // );
  // await Future.delayed(const Duration(seconds: 1));

  // --- Snapshot to local filesystem ---
  final exampleRoot = _exampleRoot();
  final cleanPath = path.replaceAll(RegExp(r'^/+|/+$'), '');
  final parts = cleanPath.isEmpty ? <String>[] : cleanPath.split('/');
  final targetDir = Directory(
    p.joinAll([exampleRoot, 'web', 'seo_snapshots', ...parts]),
  );
  if (!targetDir.existsSync()) targetDir.createSync(recursive: true);
  File(p.join(targetDir.path, 'index.html')).writeAsStringSync(fullHtml);
  debugPrint('📁 [TEST] Saved to: ${targetDir.path}${p.separator}index.html');
  await Future.delayed(const Duration(milliseconds: 100));
}

Future<void> generateAndSendSitemap(WidgetTester tester) async {
  String sitemapContent = EasySEOManager.instance.generateSitemapContent();
  if (sitemapContent.isNotEmpty) {
    await tester.runAsync(() async {
      /// ALTERNATIVE: Use a service to send the generated sitemap.xml to a REST endpoint
      /// that stores the files in your web server.
      // debugPrint('🚀 [TEST] Sending generated sitemap.xml to server!');
      // await SEOSyncService().sendSitemap(
      //     sitemapXmlContent: sitemapContent,
      // );
      // await Future.delayed(const Duration(seconds: 1));

      // --- Snapshot to local filesystem ---
      final exampleRoot = _exampleRoot();
      final targetDir = Directory(
        p.joinAll([exampleRoot, 'web']),
      );
      if (!targetDir.existsSync()) targetDir.createSync(recursive: true);
      File(p.join(targetDir.path, 'sitemap.xml')).writeAsStringSync(sitemapContent);
      debugPrint('📁 [TEST] Saved to: ${targetDir.path}${p.separator}sitemap.xml');
      await Future.delayed(const Duration(milliseconds: 100));
    });
  }
}
