part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

typedef EasySEOOnGenerateCallback = void Function(EasySEOGenerationResult generatedData);

class SeoRouteKey implements Comparable<SeoRouteKey> {
  final String path;
  final int rank;

  const SeoRouteKey({
    required this.path,
    this.rank = 0,
  });

  int get _slashCount => '/'.allMatches(path).length;

  @override
  int compareTo(SeoRouteKey other) {
    // 1. Primary Sort: Slash Count (Deeper sub-routes always move to the back)
    final slashCompare = _slashCount.compareTo(other._slashCount);
    if (slashCompare != 0) return slashCompare;

    // 2. Secondary Sort: Path String Length
    final lengthCompare = path.length.compareTo(other.path.length);
    if (lengthCompare != 0) return lengthCompare;

    // 3. Tertiary Sort: Rank (Acts as the ultimate tie-breaker for identical paths)
    // Moves 0 before 1 when the paths match perfectly
    final rankCompare = rank.compareTo(other.rank);
    if (rankCompare != 0) return rankCompare;

    // 4. Absolute Fallback: Alphabetical to prevent different sibling routes
    // from overwriting each other in memory
    return path.compareTo(other.path);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SeoRouteKey && rank == other.rank && path == other.path;

  @override
  int get hashCode => rank.hashCode ^ path.hashCode;

  @override
  String toString() => '$path [Rank: $rank]';
}

/// A singleton manager that serves as the central orchestrator for the `flutter_easy_seo` package.
///
/// `EasySEOManager` manages the active lifecycle of SEO pages (which EasySEOPage is currently active), formats URLs,
/// processes language-based paths, keeps track of dynamic urls, generates standard-compliant XML sitemaps, and exposes global
/// configurations (e.g. output options, interactive mode, additional `<head>` tags in every generated page, etc.).
///
/// ### Core Responsibilities
/// * **Registry management:** Tracks a registry of page controllers ([EasySEOPageController]) using a sorted
///   [SplayTreeMap] based on path depth, length, and rank to automatically determine the active rendering context.
/// * **Sitemap Generation:** Automates the construction of `sitemap.xml` compliant with multi-language
///   alternate links (`hreflang`) and default index mappings (`x-default`).
/// * **URL Formatting & Parsing:** Standardizes path structures, extracts language prefixes, and translates
///   routes into fully qualified URLs.
/// * **Dynamic Routing:** Extracts and monitors dynamic route matches to gather runtime pages for rendering.
///
/// ### Initialization Parameters
/// Call [init] to configure the global singleton state:
/// * [enabled] - Globally controls whether SEO generation is active.
/// * [enableFileOutput] - Writes generated HTML outputs directly to the local storage target.
/// * [enableLiveOutput] - Injects the generated HTML in the live DOM.
/// * [disableOnGenerate] - Disables executing the [onGenerate] callback. Set to true in automated widget tests to keep the [onGenerate] config of the app unchanged.
/// In a widget tester calling a REST endpoint needs to be done slightly differently than in the running flutter app.
/// * [enableInteractiveMode] - Shows a widget overlay inside the UI layout for debugging purposes and interactive generation of the HTML output.
/// * [showResultDialog] - Dictates whether a modal dialog is presented in interactiv mode to preview the generated output.
/// * [renderMode] - The [SEORenderMode] configuration (e.g. html+jsonld, html-only etc.).
/// * [onGenerate] - Callback invoked when a HTML page is generated. For example, this can be used to send the result to a rest endpoint:
/// ```dart
/// onGenerate: (EasySEOGenerationResult result) async {
///   if (result case SeoSuccess(:final fullHtml, :final currentLanguage, :final path)) {
///     await SomeRESTService().sendGeneratedData(
///       html: fullHtml,
///       language: currentLanguage,
///       path: '$path/index'
///     );
///   }
/// },
/// ```
/// * [baseUrl] - The root domain URL used to build absolute URLs (canonical/alternate links). If it is not provided and the app is run as a web-app,
/// the url will be retrieved from the current browser url.
/// * [supportedLanguages] - List of language codes used for prefix-routing structures (e.g. [['en', 'de']]). The first language in the list is considered the default language.
/// This is taken into account when generating the sitemap.xml file (the root '/' is the same page as '/en').
/// * [pages] - Set of static and dynamic routes to build the sitemap.
/// These router are automatically combined with the list of [supportedLanguages] (e.g. [['de']] and [['/products']] results in '/de/products'.
/// A route is considered dynamic when it contains a pattern like 'products/:id'. All links in generated html content that match such a dynamic route is
/// collected in a Set that can be retrieved by [getAllRoutes] for processing in a widget tester. All static and dynamic routes are added to the sitemap.xml.
/// * [headTags] - Global default meta, link, and script tags injected into the document head. For example:
/// ```dart
/// headTags: [[
///   EasySEOAppleHeadTags(title: 'Some Page Title', iconUrl: '/icons/Icon.png'),
///   EasySEOLinkTag.manifest('manifest.json'),
///   EasySEOLinkTag.icon("favicon.png"),
///   EasySEOOgTags(imageUrl: 'https://somepage.com/og_image.png', type: 'website', siteName: 'Some Page Title'),
///   EasySEOTwitterTags(site: '@somepage')
/// ]]
/// ```
/// * [pathProvider] - Optional delegate to retrieve the current active path from the routing context.
///   When omitted, the path is resolved through a built-in fallback chain:
///   1. [pathProvider] is **required** when using routers that store symbolic route names instead of
///   URL paths in `settings.name` (e.g. **GoRouter**, **Beamer**). For example:
///       ```dart
///       pathProvider: (context) => GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration.uri.toString(),
///       ```
///   2. [ModalRoute.of(context)?.settings.name] — works automatically for **Navigator 1.0**,
///      **auto_route**, **fluro**, and any router that stores the full path in `settings.name`.
///   3. [URLHelper().getCurrentPath()] — browser URL on web (hash-routing aware), empty on native.
///
class EasySEOManager {
  // singleton
  EasySEOManager._internal();
  static final EasySEOManager _instance = EasySEOManager._internal();
  static EasySEOManager get instance => _instance;

  // --- Instance Properties ---

  // ValueNotifiers are now instance-level, accessible via EasySEOConfig.instance
  final ValueNotifier<bool> enabled = ValueNotifier(true);
  final ValueNotifier<bool> enableFileOutput = ValueNotifier(false);
  final ValueNotifier<bool> enableLiveOutput = ValueNotifier(false);
  final ValueNotifier<bool> disableOnGenerate = ValueNotifier(false);
  final ValueNotifier<bool> enableInteractiveMode = ValueNotifier(false);
  final ValueNotifier<bool> showResultDialog = ValueNotifier(true);
  final ValueNotifier<bool> showHighlights = ValueNotifier(false);
  final ValueNotifier<SEORenderMode> renderMode = ValueNotifier(SEORenderMode.full);
  bool interactiveMinimized = false;

  int _overlayRefCount = 0;
  OverlayEntry? _overlayEntry;

  void showOverlay(BuildContext context) {
    _overlayRefCount++;
    if (_overlayRefCount == 1) {
      _overlayEntry = OverlayEntry(
        builder: (_) => const Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: EasySEOInteractiveOverlay(),
            ),
          ),
        ),
      );
      Navigator.of(context, rootNavigator: true).overlay!.insert(_overlayEntry!);
    }
  }

  void hideOverlay() {
    _overlayRefCount--;
    if (_overlayRefCount <= 0) {
      _overlayRefCount = 0;
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  String? baseUrl;
  List<String> supportedLanguages = const [];
  List<String> pages = const [];
  List<EasySEOHeadTagSource> headTags = const [];
  List<String> dynamicPathPatterns = const [];

  final Set<String> _gatheredPages = {};

  EasySEOOnGenerateCallback? onGenerate;

  /// Optional provider to get the current path from the context (e.g. from GoRouter)
  String? Function(BuildContext)? pathProvider;

  // This is now directly accessible via EasySEOConfig.instance.globals
  final Map<String, BuildContext> globals = {};

  // ------ EasySEO widget registry ----------
  // The stack of registered controllers
  // Using splay tree to sort depth of EasySEOPage controllers
  // so that it does not rely on mounting order.
  final _stack = SplayTreeMap<SeoRouteKey, EasySEOPageController>((key1, key2) => key1.compareTo(key2));

  /// Returns the controller that currently has authority (the deepest/newest one)
  EasySEOPageController? get activeController => _stack.values.lastOrNull;

  bool register(SeoRouteKey key, EasySEOPageController controller) {
    final existing = _stack[key];
    if (existing != null && existing != controller) return false;
    _stack.removeWhere((k, c) => k.rank == key.rank && k.path != key.path);
    debugPrint('📦 [EasySEO] Registering: $key');
    _stack[key] = controller;

    final parsed = parsePath(key.path);
    if (shouldGather(parsed.pagePath)) {
      String pagePath = parsed.pagePath;
      if (pagePath.isNotEmpty && !pagePath.startsWith('/')) {
        pagePath = '/$pagePath';
      }
      if (pagePath == '/') {
        pagePath = '';
      }
      _gatheredPages.add(pagePath);
    }
    return true;
  }

  void unregister(SeoRouteKey key, EasySEOPageController controller) {
    if (_stack[key] != controller) return;
    debugPrint('🗑️ [EasySEO] Unregistering controller: $key, ${_stack.length}');
    _stack.remove(key);
  }

  /// Global trigger for the headless test or automated syncs
  Future<EasySEOGenerationResult> generateActive({SEORenderMode? mode}) async {
    debugPrint('🗑️ [EasySEO] generateActive() for: ${_stack.keys.lastOrNull ?? "unknown"}');
    final controller = activeController;
    if (controller == null) return SeoSkipped("No active EasySEO controller found in registry.");
    return await controller.generate(mode: mode);
  }

  bool seoPageIsReady() {
    // TODO sealed bool class
    final controller = activeController;
    if (controller == null) {
      debugPrint('⚠️ No active EasySEO controller found in registry.');
      return true;
    }
    return controller.isReady();
  }

  @visibleForTesting
  void clear() {
    _stack.clear();
    _gatheredPages.clear();
    interactiveMinimized = false;
  }

  /// Checks if a page path matches any registered dynamic path pattern.
  bool shouldGather(String pagePath) {
    return dynamicPathPatterns.any((pattern) => URLHelper().isPathMatch(pagePath, pattern));
  }

  /// Manually add a dynamic route path to the gathered list
  void addGatheredPage(String path) {
    final parsed = parsePath(path);
    String pagePath = parsed.pagePath;
    if (pagePath.isNotEmpty && !pagePath.startsWith('/')) {
      pagePath = '/$pagePath';
    }
    if (pagePath == '/') {
      pagePath = '';
    }
    _gatheredPages.add(pagePath);
  }

  /// Extracts all URLs from the given HTML string (e.g. href attributes)
  /// and gathers them if they match any registered dynamic path patterns.
  void gatherFromHtml(String html) {
    final hrefRegex = RegExp(r'href="([^"]+)"');
    final matches = hrefRegex.allMatches(html);
    for (final match in matches) {
      final href = match.group(1);
      if (href != null && href.isNotEmpty) {
        final uri = Uri.tryParse(href);
        if (uri != null) {
          final path = uri.path;
          final parsed = parsePath(path);
          if (shouldGather(parsed.pagePath)) {
            addGatheredPage(path);
          }
        }
      }
    }
  }
  /// Returns the current active path using a layered fallback strategy:
  /// 1. [pathProvider] — explicit user-configured delegate (GoRouter, Beamer).
  /// 2. [ModalRoute.of(context)?.settings.name] — native route name (Navigator 1.0, auto_route, fluro).
  /// 3. [URLHelper().getCurrentPath()] — browser URL on web, empty string on native.
  String getCurrentPath(BuildContext context) {
    // Layer 1: Explicit pathProvider (user-configured, e.g., GoRouter)
    if (pathProvider != null) {
      final path = pathProvider!(context);
      if (path != null && path.isNotEmpty) return path;
    }

    // Layer 2: ModalRoute from the build context (Navigator 1.0, auto_route, fluro)
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null &&
        modalRoute.settings.name != null &&
        modalRoute.settings.name!.isNotEmpty) {
      return modalRoute.settings.name!;
    }

    // Layer 3: Browser URL via URLHelper (web) / '' (native)
    return URLHelper().getCurrentPath();
  }
  // ------ EasySEO widget registry ----------

  /// Initialize the settings.
  /// You can call this via EasySEOConfig.instance.init(...)
  void init({
    bool enabled = true,
    bool enableFileOutput = false,
    bool enableLiveOutput = false,
    bool disableOnGenerate = false,
    bool enableInteractiveMode = false,
    bool showResultDialog = true,
    SEORenderMode? renderMode,
    EasySEOOnGenerateCallback? onGenerate,
    String? baseUrl,
    List<String> supportedLanguages = const [],
    List<String> pages = const [],
    List<EasySEOHeadTagSource> headTags = const [],
    String? Function(BuildContext)? pathProvider,
  }) {
    this.enabled.value = enabled;
    this.enableFileOutput.value = enableFileOutput;
    this.enableLiveOutput.value = enableLiveOutput;
    this.disableOnGenerate.value = disableOnGenerate;
    this.enableInteractiveMode.value = enableInteractiveMode;
    this.showResultDialog.value = showResultDialog;
    if (renderMode != null) this.renderMode.value = renderMode;
    this.onGenerate = onGenerate;
    this.baseUrl = baseUrl;
    this.supportedLanguages = supportedLanguages;
    this.headTags = headTags;
    this.pathProvider = pathProvider;

    // Automatically extract any dynamic patterns containing colons from the pages list
    final List<String> staticPages = [];
    final List<String> extractedDynamicPatterns = [];

    for (final p in pages) {
      if (p.contains(':')) {
        if (!extractedDynamicPatterns.contains(p)) {
          extractedDynamicPatterns.add(p);
        }
      } else {
        staticPages.add(p);
      }
    }

    this.pages = staticPages;
    dynamicPathPatterns = extractedDynamicPatterns;
  }

  /// Helper to check if any SEO output is active
  bool get isActive => enableFileOutput.value || enableLiveOutput.value || !disableOnGenerate.value;

  static String _encodePath(String path) {
    return path.split('/').map((s) {
      try {
        return Uri.encodeComponent(Uri.decodeComponent(s));
      } catch (_) {
        return Uri.encodeComponent(s);
      }
    }).join('/');
  }

  /// Formats a path into a full URL using the configured [baseUrl]
  String formatFullUrl(String path) {
    String? bUrl = baseUrl;
    if (bUrl == null || bUrl.isEmpty) {
      final host = PlatformHelper.host;
      final protocol = PlatformHelper.protocol;
      if (host != null && protocol != null) {
        bUrl = '$protocol//$host';
      }
    }

    if (bUrl == null || bUrl.isEmpty) return path;

    final cleanBase = bUrl.endsWith('/') ? bUrl.substring(0, bUrl.length - 1) : bUrl;
    final cleanPath = _encodePath((path.startsWith('/') ? path : '/$path').toLowerCase());
    return '$cleanBase$cleanPath';
  }

  /// Helper to generate the correct relative path for a given language
  String _getUrlForLang(String? lang, String pagePath, {String cleanBase = ''}) {
    final String? firstLang = supportedLanguages.firstOrNull;
    final targetLang = lang ?? firstLang;
    final encodedPath = _encodePath(pagePath);

    // Root case: if it's the first language and root path, omit the prefix
    if (pagePath.isEmpty && targetLang == firstLang) {
      return '$cleanBase/';
    }

    // All other cases (subpages or non-primary languages) use the prefix
    if (targetLang != null) {
      return '$cleanBase/$targetLang$encodedPath';
    }

    // Fallback for neutral subpages (shouldn't normally happen with exhaustive langs)
    return pagePath.isEmpty ? '$cleanBase/' : '$cleanBase$encodedPath';
  }

  /// Returns a list of all routes that can be built from supportedLanguages and pages.
  List<String> getAllRoutes({bool gatheredOnly = false}) {
    final languages = UnmodifiableListView(supportedLanguages);
    final List<String> rawPages = pages.isEmpty ? [''] : pages;

    final Set<String> uniqueCleanPages = {};
    if (!gatheredOnly) {
      for (final p in rawPages) {
        if (p.contains(':')) continue;
        String cp = p.trim();
        if (cp.isNotEmpty && !cp.startsWith('/')) cp = '/$cp';
        if (cp == '/') cp = '';
        uniqueCleanPages.add(cp);
      }
    }

    for (final gp in _gatheredPages) {
      String cp = gp.trim();
      if (cp.isNotEmpty && !cp.startsWith('/')) cp = '/$cp';
      if (cp == '/') cp = '';
      uniqueCleanPages.add(cp);
    }

    final List<String> allRoutes = [];

    for (final cleanPage in uniqueCleanPages) {
      if (languages.isEmpty) {
        allRoutes.add(cleanPage.isEmpty ? '/' : cleanPage);
      } else {
        for (final currentLang in languages) {
          allRoutes.add(_getUrlForLang(currentLang, cleanPage));
        }
      }
    }
    return allRoutes;
  }

  /// Generate sitemap.xml content
  String generateSitemapContent() {
    final baseUrl = this.baseUrl;
    if (baseUrl == null || baseUrl.isEmpty) return '';

    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final languages = UnmodifiableListView(supportedLanguages);
    final List<String> rawPages = pages.isEmpty ? [''] : pages;

    final Set<String> uniqueCleanPages = {};
    for (final p in rawPages) {
      if (p.contains(':')) continue;
      String cp = p.trim();
      if (cp.isNotEmpty && !cp.startsWith('/')) cp = '/$cp';
      if (cp == '/') cp = '';
      uniqueCleanPages.add(cp);
    }

    for (final gp in _gatheredPages) {
      String cp = gp.trim();
      if (cp.isNotEmpty && !cp.startsWith('/')) cp = '/$cp';
      if (cp == '/') cp = '';
      uniqueCleanPages.add(cp);
    }

    final StringBuffer sitemap = StringBuffer();
    sitemap.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sitemap.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"');
    sitemap.writeln('        xmlns:xhtml="http://www.w3.org/1999/xhtml">');

    final String? firstLang = languages.firstOrNull;

    for (final cleanPage in uniqueCleanPages) {
      String priority = "0.8";
      if (cleanPage.contains('offers') || cleanPage.isEmpty) {
        priority = "1.0";
      } else if (cleanPage.contains('compare')) {
        priority = "0.8";
      }

      if (languages.isEmpty) {
        final displayLoc = cleanPage.isEmpty ? '$cleanBase/' : '$cleanBase$cleanPage';
        sitemap.writeln('  <url>');
        sitemap.writeln('    <loc>$displayLoc</loc>');
        sitemap.writeln('    <priority>$priority</priority>');
        sitemap.writeln('    <changefreq>daily</changefreq>');
        sitemap.writeln('  </url>');
        continue;
      }

      for (final currentLang in languages) {
        final displayLoc = _getUrlForLang(currentLang, cleanPage, cleanBase: cleanBase);

        sitemap.writeln('  <url>');
        sitemap.writeln('    <loc>$displayLoc</loc>');

        for (final altLang in languages) {
          final altUrl = _getUrlForLang(altLang, cleanPage, cleanBase: cleanBase);
          sitemap.writeln('    <xhtml:link rel="alternate" hreflang="$altLang" href="$altUrl"/>');
        }

        if (firstLang != null) {
          final defaultUrl = _getUrlForLang(firstLang, cleanPage, cleanBase: cleanBase);
          sitemap.writeln('    <xhtml:link rel="alternate" hreflang="x-default" href="$defaultUrl"/>');
        }

        sitemap.writeln('    <priority>$priority</priority>');
        sitemap.writeln('    <changefreq>daily</changefreq>');
        sitemap.writeln('  </url>');
      }
    }

    sitemap.writeln('</urlset>');
    return sitemap.toString();
  }

  /// Returns the effective base URL without trailing slash (falls back to PlatformHelper if empty)
  String getEffectiveCleanBaseUrl() {
    String? bUrl = baseUrl;
    if (bUrl == null || bUrl.isEmpty) {
      final host = PlatformHelper.host;
      final protocol = PlatformHelper.protocol;
      if (host != null && protocol != null) {
        bUrl = '$protocol//$host';
      }
    }
    if (bUrl == null || bUrl.isEmpty) return '';
    return bUrl.endsWith('/') ? bUrl.substring(0, bUrl.length - 1) : bUrl;
  }

  /// Parses a given path into a [pagePath] (language-independent page path)
  /// and the [detectedLang] (if a language prefix is present in the path).
  ({String pagePath, String? detectedLang}) parsePath(String path) {
    final cleanPath = path.trim();
    // Split the path to check segments
    final segments = cleanPath.split('/').where((s) => s.isNotEmpty).toList();

    String? detectedLang;
    List<String> pageSegments = segments;
    if (segments.isNotEmpty && supportedLanguages.contains(segments.first)) {
      detectedLang = segments.first;
      pageSegments = segments.sublist(1);
    }

    final pagePath = pageSegments.isEmpty ? '' : '/${pageSegments.join('/')}';
    return (pagePath: pagePath, detectedLang: detectedLang);
  }

  /// Unified resolver that takes any path, parses it, and returns the canonical, alternate, and x-default URLs
  EasySEOUrls resolveSeoUrls(String path) {
    final parsed = parsePath(path.toLowerCase());
    final pagePath = parsed.pagePath;
    final detectedLang = parsed.detectedLang;
    final cleanBase = getEffectiveCleanBaseUrl();

    // Canonical language defaults to the first supported language if none is detected.
    final canonicalLang = detectedLang ?? supportedLanguages.firstOrNull;
    final canonicalUrl = _getUrlForLang(canonicalLang, pagePath, cleanBase: cleanBase);

    final Map<String, String> alternateUrls = {};
    for (final lang in supportedLanguages) {
      alternateUrls[lang] = _getUrlForLang(lang, pagePath, cleanBase: cleanBase);
    }

    String? xDefaultUrl;
    final firstLang = supportedLanguages.firstOrNull;
    if (firstLang != null) {
      xDefaultUrl = _getUrlForLang(firstLang, pagePath, cleanBase: cleanBase);
    }

    return EasySEOUrls(
      canonicalUrl: canonicalUrl,
      alternateUrls: alternateUrls,
      xDefaultUrl: xDefaultUrl,
    );
  }
}

class EasySEOUrls {
  final String canonicalUrl;
  final Map<String, String> alternateUrls;
  final String? xDefaultUrl;

  const EasySEOUrls({
    required this.canonicalUrl,
    required this.alternateUrls,
    this.xDefaultUrl,
  });
}
