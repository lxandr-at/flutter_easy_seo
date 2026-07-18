import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  setUp(() {
    EasySEOManager.instance.clear();
    EasySEOManager.instance.init(
      baseUrl: 'https://preisvergleich.lxandr.at',
      supportedLanguages: ['de', 'en', 'fr', 'tr', 'hr'],
      pages: ['/'],
    );
  });

  group('EasySEOManager Path Parsing and URL Resolving', () {
    test('parsePath splits language and page paths correctly', () {
      final manager = EasySEOManager.instance;

      // Root path without language prefix
      var parsed = manager.parsePath('/');
      expect(parsed.pagePath, equals(''));
      expect(parsed.detectedLang, isNull);

      // Root path with default language prefix
      parsed = manager.parsePath('/de');
      expect(parsed.pagePath, equals(''));
      expect(parsed.detectedLang, equals('de'));

      // Root path with other language prefix
      parsed = manager.parsePath('/en');
      expect(parsed.pagePath, equals(''));
      expect(parsed.detectedLang, equals('en'));

      // Sub-page with language prefix
      parsed = manager.parsePath('/en/offers');
      expect(parsed.pagePath, equals('/offers'));
      expect(parsed.detectedLang, equals('en'));

      // Sub-page without language prefix
      parsed = manager.parsePath('/offers');
      expect(parsed.pagePath, equals('/offers'));
      expect(parsed.detectedLang, isNull);
    });

    test('resolveSeoUrls provides consistent URLs for / and /de', () {
      final manager = EasySEOManager.instance;

      final urlsFromRoot = manager.resolveSeoUrls('/');
      final urlsFromDe = manager.resolveSeoUrls('/de');

      // Canonical URL should point to root for both
      expect(urlsFromRoot.canonicalUrl, equals('https://preisvergleich.lxandr.at/'));
      expect(urlsFromDe.canonicalUrl, equals('https://preisvergleich.lxandr.at/'));

      // X-Default should also point to root
      expect(urlsFromRoot.xDefaultUrl, equals('https://preisvergleich.lxandr.at/'));
      expect(urlsFromDe.xDefaultUrl, equals('https://preisvergleich.lxandr.at/'));

      // Alternates must be absolutely identical
      expect(urlsFromRoot.alternateUrls, equals(urlsFromDe.alternateUrls));

      // Individual alternates check
      expect(urlsFromRoot.alternateUrls['de'], equals('https://preisvergleich.lxandr.at/'));
      expect(urlsFromRoot.alternateUrls['en'], equals('https://preisvergleich.lxandr.at/en'));
      expect(urlsFromRoot.alternateUrls['fr'], equals('https://preisvergleich.lxandr.at/fr'));
      expect(urlsFromRoot.alternateUrls['tr'], equals('https://preisvergleich.lxandr.at/tr'));
      expect(urlsFromRoot.alternateUrls['hr'], equals('https://preisvergleich.lxandr.at/hr'));
    });

    test('resolveSeoUrls provides consistent URLs for sub-pages like /offers and /de/offers', () {
      final manager = EasySEOManager.instance;

      final urlsFromOffers = manager.resolveSeoUrls('/offers');
      final urlsFromDeOffers = manager.resolveSeoUrls('/de/offers');

      // Both should resolve to /de/offers as canonical URL
      expect(urlsFromOffers.canonicalUrl, equals('https://preisvergleich.lxandr.at/de/offers'));
      expect(urlsFromDeOffers.canonicalUrl, equals('https://preisvergleich.lxandr.at/de/offers'));

      expect(urlsFromOffers.xDefaultUrl, equals('https://preisvergleich.lxandr.at/de/offers'));
      expect(urlsFromDeOffers.xDefaultUrl, equals('https://preisvergleich.lxandr.at/de/offers'));

      expect(urlsFromOffers.alternateUrls, equals(urlsFromDeOffers.alternateUrls));
      expect(urlsFromOffers.alternateUrls['en'], equals('https://preisvergleich.lxandr.at/en/offers'));
    });
  });

  group('EasySEOPage Head Tag Output Consistency', () {
    testWidgets('EasySEOPage renders correct canonical and alternates for root path /', (WidgetTester tester) async {
      String? capturedHead;

      EasySEOManager.instance.onGenerate = (EasySEOGenerationResult gen) {
        if (gen case SeoSuccess(:final headContent)) {
          capturedHead = headContent;
        }
      };

      EasySEOManager.instance.pathProvider = (_) => '/';

      await tester.pumpWidget(
        MaterialApp(
          home: EasySEOPage(
            title: 'Home Page',
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(capturedHead, isNotNull);
      expect(
          capturedHead,
          contains(
              '<link data-easy-seo="link:rel:canonical" rel="canonical" href="https://preisvergleich.lxandr.at/">',),);
      expect(
          capturedHead,
          contains(
              '<link data-easy-seo="link:alternate:de" rel="alternate" href="https://preisvergleich.lxandr.at/" hreflang="de">',),);
      expect(
          capturedHead,
          contains(
              '<link data-easy-seo="link:alternate:en" rel="alternate" href="https://preisvergleich.lxandr.at/en" hreflang="en">',),);
      expect(
          capturedHead,
          contains(
              '<link data-easy-seo="link:alternate:x-default" rel="alternate" href="https://preisvergleich.lxandr.at/" hreflang="x-default">',),);
    });

    testWidgets('EasySEOPage renders correct canonical and alternates for default language path /de',
        (WidgetTester tester) async {
      String? capturedHead;

      EasySEOManager.instance.onGenerate = (EasySEOGenerationResult gen) {
        if (gen case SeoSuccess(:final headContent)) {
          capturedHead = headContent;
        }
      };

      EasySEOManager.instance.pathProvider = (_) => '/de';

      await tester.pumpWidget(
        MaterialApp(
          home: EasySEOPage(
            title: 'Home Page',
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(capturedHead, isNotNull);
      expect(
          capturedHead,
          contains(
              '<link data-easy-seo="link:rel:canonical" rel="canonical" href="https://preisvergleich.lxandr.at/">',),);
      expect(
          capturedHead,
          contains(
              '<link data-easy-seo="link:alternate:de" rel="alternate" href="https://preisvergleich.lxandr.at/" hreflang="de">',),);
      expect(
          capturedHead,
          contains(
              '<link data-easy-seo="link:alternate:en" rel="alternate" href="https://preisvergleich.lxandr.at/en" hreflang="en">',),);
      expect(
          capturedHead,
          contains(
              '<link data-easy-seo="link:alternate:x-default" rel="alternate" href="https://preisvergleich.lxandr.at/" hreflang="x-default">',),);
    });
  });

  group('Interactive Mode Overlay', () {
    testWidgets('EasySEOInteractiveOverlay is shown when enableInteractiveMode is true', (WidgetTester tester) async {
      EasySEOManager.instance.init(
        enableInteractiveMode: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EasySEOPage(
            title: 'Interactive Test',
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The overlay widget should be visible
      expect(find.byType(EasySEOInteractiveOverlay), findsOneWidget);
      expect(find.text('Generate HTML'), findsOneWidget);
      expect(find.text('Generate Sitemap'), findsOneWidget);
    });

    testWidgets('EasySEOInteractiveOverlay is NOT shown when enableInteractiveMode is false',
        (WidgetTester tester) async {
      EasySEOManager.instance.init(
        enableInteractiveMode: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EasySEOPage(
            title: 'Interactive Test',
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The overlay widget should NOT be visible
      expect(find.byType(EasySEOInteractiveOverlay), findsNothing);
    });

    testWidgets('EasySEOInteractiveOverlay toggles update manager settings', (WidgetTester tester) async {
      final manager = EasySEOManager.instance;
      manager.init(
        enableInteractiveMode: true,
      );
      manager.disableOnGenerate.value = false;
      manager.enableLiveOutput.value = false;
      manager.enableFileOutput.value = false;
      manager.showResultDialog.value = false;

      await tester.pumpWidget(
        MaterialApp(
          home: EasySEOPage(
            title: 'Interactive Test',
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the "Auto Gen" toggle button and tap it to disable
      await tester.tap(find.text('Auto Gen'));
      await tester.pumpAndSettle();
      expect(manager.disableOnGenerate.value, isTrue); // Auto Gen is false -> disableOnGenerate is true

      // Find the "Live Out" toggle button and tap it to enable
      await tester.tap(find.text('Live Out'));
      await tester.pumpAndSettle();
      expect(manager.enableLiveOutput.value, isTrue);

      // Find the "File Out" toggle button and tap it to enable
      await tester.tap(find.text('File Out'));
      await tester.pumpAndSettle();
      expect(manager.enableFileOutput.value, isTrue);

      // Find the "Show Popup" toggle button and tap it to enable
      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();
      expect(manager.showResultDialog.value, isTrue);
    });
  });

  group('Sitemap XML Consistency', () {
    test('generateSitemapContent output matches resolved alternate tags', () {
      final sitemap = EasySEOManager.instance.generateSitemapContent();

      // The loc for the root/default page should be base URL
      expect(sitemap, contains('<loc>https://preisvergleich.lxandr.at/</loc>'));
      expect(sitemap, contains('<xhtml:link rel="alternate" hreflang="de" href="https://preisvergleich.lxandr.at/"/>'));
      expect(
          sitemap, contains('<xhtml:link rel="alternate" hreflang="en" href="https://preisvergleich.lxandr.at/en"/>'),);
      expect(sitemap,
          contains('<xhtml:link rel="alternate" hreflang="x-default" href="https://preisvergleich.lxandr.at/"/>'),);
    });
  });

  group('Dynamic Route Gathering & Regex Pattern Matching', () {
    setUp(() {
      EasySEOManager.instance.clear();
      EasySEOManager.instance.init(
        baseUrl: 'https://preisvergleich.lxandr.at',
        supportedLanguages: ['de', 'en', 'fr'],
        pages: ['/', 'compare/:id', 'products/:productId'],
      );
    });

    test('shouldGather accurately matches colon-placeholders using compiled RegExp', () {
      final manager = EasySEOManager.instance;

      // Matching patterns
      expect(manager.shouldGather('/compare/123'), isTrue);
      expect(manager.shouldGather('/compare/shoes-abc'), isTrue);
      expect(manager.shouldGather('/products/hat-456'), isTrue);

      // Non-matching patterns
      expect(manager.shouldGather('/compare/123/edit'), isFalse);
      expect(manager.shouldGather('/compare'), isFalse);
      expect(manager.shouldGather('/other/123'), isFalse);
      expect(manager.shouldGather('/products/shoes/456'), isFalse);
    });

    test('addGatheredPage manually appends matching route with alternates to sitemap', () {
      final manager = EasySEOManager.instance;
      manager.addGatheredPage('/en/compare/999');

      final sitemap = manager.generateSitemapContent();
      expect(sitemap, contains('<loc>https://preisvergleich.lxandr.at/en/compare/999</loc>'));
      expect(
          sitemap,
          contains(
              '<xhtml:link rel="alternate" hreflang="de" href="https://preisvergleich.lxandr.at/de/compare/999"/>',),);
      expect(
          sitemap,
          contains(
              '<xhtml:link rel="alternate" hreflang="fr" href="https://preisvergleich.lxandr.at/fr/compare/999"/>',),);
    });

    test('register() automatically gathers matching paths during walkthrough', () {
      final manager = EasySEOManager.instance;
      final controller = EasySEOPageController();

      // Register non-matching page path
      manager.register(SeoRouteKey(path: '/de/other/route'), controller);
      expect(manager.getAllRoutes(), isNot(contains('/de/other/route')));

      // Register matching page path in DE language
      manager.register(SeoRouteKey(path: '/de/compare/555'), controller);

      final allRoutes = manager.getAllRoutes();
      expect(allRoutes, contains('/de/compare/555'));
      expect(allRoutes, contains('/en/compare/555'));
      expect(allRoutes, contains('/fr/compare/555'));

      // Sitemap should contain the DE, EN, and FR alternatives for compare/555
      final sitemap = manager.generateSitemapContent();
      expect(sitemap, contains('<loc>https://preisvergleich.lxandr.at/de/compare/555</loc>'));
      expect(sitemap, contains('<loc>https://preisvergleich.lxandr.at/en/compare/555</loc>'));
      expect(sitemap, contains('<loc>https://preisvergleich.lxandr.at/fr/compare/555</loc>'));
    });

    test(
        'pages list containing dynamic routes with colons automatically filters them out of static URLs and treats them as dynamic patterns',
        () {
      final manager = EasySEOManager.instance;
      manager.init(
        baseUrl: 'https://preisvergleich.lxandr.at',
        supportedLanguages: ['de', 'en'],
        pages: ['/', 'compare/:productId'], // Accidentally put dynamic pattern here
      );

      // Verify that 'compare/:productId' was filtered out of static pages list
      expect(manager.pages, isNot(contains('compare/:productId')));
      expect(manager.pages, contains('/'));

      // Verify that 'compare/:productId' was automatically registered as a dynamic path pattern
      expect(manager.dynamicPathPatterns, contains('compare/:productId'));

      // Verify that the sitemap never literally contains the placeholder :productId
      final sitemap = manager.generateSitemapContent();
      expect(sitemap, isNot(contains(':productId')));
    });
  });
}
