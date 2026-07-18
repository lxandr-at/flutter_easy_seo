part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Callback invoked after a page is generated.
///
/// Receives the [EasySEOGenerationResult] (either [SeoSuccess] with the full
/// HTML document or [SeoSkipped] when generation was suppressed). Use this to
/// send the result to a REST endpoint, write to disk, or integrate with other
/// services.
typedef EasySEOOnGenerateCallback = void Function(EasySEOGenerationResult generatedData);

/// Sortable key for the page-controller registry.
///
/// Used as the key in the [SplayTreeMap] that stores registered
/// [EasySEOPageController] instances. The [compareTo] ordering ensures that
/// deeper, longer, or lower-ranked paths resolve predictably.
///
/// The comparison follows a four-level cascade:
/// 1. **Path depth** (slash count) — shallower routes sort first.
/// 2. **Path length** — shorter strings sort before longer ones.
/// 3. **Explicit [rank]** — within identical paths, rank 0 sorts before rank 1.
/// 4. **Alphabetical** — final tie-breaker to guarantee total order.
@visibleForTesting
class SeoRouteKey implements Comparable<SeoRouteKey> {
  /// The URL path string for this route key.
  final String path;

  /// Explicit rank for tie-breaking identical paths.
  ///
  /// A lower rank sorts before a higher one when [path] and depth match.
  /// This is used to resolve overlapping route registrations (e.g. a parent
  /// page registered before its child).
  final int rank;

  const SeoRouteKey({
    required this.path,
    this.rank = 0,
  });

  int get _slashCount => '/'.allMatches(path).length;

  /// Compares this key with [other] using a four-level cascade:
  ///
  /// 1. **Slash count** — fewer slashes (shallower routes) sort first.
  /// 2. **Path length** — shorter strings before longer ones.
  /// 3. **Rank** — within identical paths, lower rank sorts first.
  /// 4. **Alphabetical** — final tie-breaker for sibling routes.
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

  /// Equality based on [path] and [rank].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SeoRouteKey && rank == other.rank && path == other.path;

  /// Combined hash of [rank] and [path].
  @override
  int get hashCode => rank.hashCode ^ path.hashCode;

  /// Formatted as `$path [Rank: $rank]`.
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
///   1. [pathProvider] is **required** for most declarative routers (**GoRouter**, **auto_route**,
///   **Beamer**) because they store symbolic route names or keys in `ModalRoute.settings.name`
///   instead of URL paths. Examples:
///       ```dart
///       // GoRouter
///       pathProvider: (context) => GoRouter.maybeOf(context)
///           ?.routerDelegate.currentConfiguration.uri.toString(),
///       // auto_route
///       pathProvider: (context) => context.router.currentPath,
///       // Beamer
///       pathProvider: (context) =>
///           (Beamer.of(context).currentBeamLocation.state as BeamState).uri.toString(),
///       ```
///   2. [ModalRoute.of(context)?.settings.name] — works automatically only for **Navigator 1.0**
///      (e.g. vanilla `MaterialApp`, **fluro**), where `settings.name` equals the URL path.
///   3. [URLHelper().getCurrentPath()] — browser URL on web (hash-routing aware), empty on native.
///
class EasySEOManager {
  // singleton
  EasySEOManager._internal();
  static final EasySEOManager _instance = EasySEOManager._internal();

  /// Global singleton instance of the SEO manager.
  ///
  /// All configuration and generated state is accessed through this instance.
  static EasySEOManager get instance => _instance;

  // --- Instance Properties ---

  /// Globally controls whether SEO generation is active.
  ///
  /// When `false`, all page generation and HTML output is suppressed.
  final ValueNotifier<bool> enabled = ValueNotifier(true);

  /// When `true`, generated HTML files are written to the local storage target.
  final ValueNotifier<bool> enableFileOutput = ValueNotifier(false);

  /// When `true`, generated HTML is injected into the live DOM.
  final ValueNotifier<bool> enableLiveOutput = ValueNotifier(false);

  /// Disables the [onGenerate] callback.
  ///
  /// Set to `true` in automated widget tests to prevent the callback from
  /// firing without altering the app's [onGenerate] configuration.
  final ValueNotifier<bool> disableOnGenerate = ValueNotifier(false);

  /// Shows a widget overlay inside the UI for debugging and interactive HTML
  /// generation.
  final ValueNotifier<bool> enableInteractiveMode = ValueNotifier(false);

  /// Dictates whether a modal dialog is shown in interactive mode to preview
  /// the generated output.
  final ValueNotifier<bool> showResultDialog = ValueNotifier(true);

  /// Highlights SEO wrapper widgets with coloured debug borders.
  final ValueNotifier<bool> showHighlights = ValueNotifier(false);

  /// Controls the rendering format (microdata, JSON-LD, or both).
  ///
  /// Passed down to [SEOHtml.toHtmlString] during page generation.
  final ValueNotifier<SEORenderMode> renderMode = ValueNotifier(SEORenderMode.full);
  bool _interactiveMinimized = false;
  final ValueNotifier<Offset?> _panelPosition = ValueNotifier(null);
  final ValueNotifier<Size?> _panelSize = ValueNotifier(null);

  int _overlayRefCount = 0;
  OverlayEntry? _overlayEntry;

  OverlayEntry? get _panelOverlayEntry => _overlayEntry;

  void _showOverlay(BuildContext context) {
    _overlayRefCount++;
    if (_overlayRefCount == 1) {
      _overlayEntry = OverlayEntry(
        builder: (_) => const _PanelPositioner(
          defaultChild: Material(
            type: MaterialType.transparency,
            child: Center(child: EasySEOInteractiveOverlay()),
          ),
          customChild: Material(
            type: MaterialType.transparency,
            child: EasySEOInteractiveOverlay(),
          ),
        ),
      );
      Navigator.of(context, rootNavigator: true).overlay!.insert(_overlayEntry!);
    }
  }

  void _reclampPanelPosition(Size screen) {
    final position = _panelPosition.value;
    if (position == null) return;
    final size = _panelSize.value;
    final clampW = (size?.width ?? 56).clamp(56, screen.width);
    final clampH = (size?.height ?? 56).clamp(56, screen.height);
    final clamped = Offset(
      position.dx.clamp(0, screen.width - clampW),
      position.dy.clamp(0, screen.height - clampH),
    );
    if (clamped != position) {
      _panelPosition.value = clamped;
    }
  }

  void _hideOverlay() {
    _overlayRefCount--;
    if (_overlayRefCount <= 0) {
      _overlayRefCount = 0;
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  String? _baseUrl;

  /// The root domain URL used to build absolute URLs (canonical, alternate).
  ///
  /// If not provided and the app runs as a web app, the URL is retrieved from
  /// the current browser URL at generation time. When `null`, relative paths
  /// are returned as-is by [formatFullUrl].
  String? get baseUrl => _baseUrl;

  List<String> _supportedLanguages = const [];

  /// Language codes used for prefix-routing (e.g. `['en', 'de']`).
  ///
  /// The first language is the default, which may map to `/` without a prefix.
  /// These are used when generating the sitemap and resolving alternate URLs.
  List<String> get supportedLanguages => _supportedLanguages;

  List<String> _pages = const [];

  /// Static route paths used to build the sitemap.
  ///
  /// Dynamic patterns (containing `:`) are automatically extracted into
  /// [dynamicPathPatterns] during [init] and excluded from this list.
  List<String> get pages => _pages;

  List<EasySEOHeadTagSource> _headTags = const [];

  /// Global default head tag sources injected into every generated page.
  ///
  /// These are merged with per-page head tags (from [EasySEOPage.headTags])
  /// when [EasySEOPage.includeGlobals] is `true`.
  List<EasySEOHeadTagSource> get headTags => _headTags;

  List<String> _dynamicPathPatterns = const [];

  /// Dynamic route patterns auto-extracted from [pages] during [init].
  ///
  /// Patterns contain `:` segments (e.g. `products/:id`). URLs in generated
  /// HTML that match these patterns are automatically gathered via
  /// [shouldGather] / [addGatheredPage] so they appear in the sitemap.
  @visibleForTesting
  List<String> get dynamicPathPatterns => _dynamicPathPatterns;

  final Set<String> _gatheredPages = {};

  EasySEOOnGenerateCallback? onGenerate;

  /// Optional provider to get the current path from the context.
  /// Required for GoRouter, auto_route, Beamer — routers that store symbolic
  /// names in `settings.name` instead of the actual URL path.
  String? Function(BuildContext)? pathProvider;

  final Map<String, BuildContext> _globals = {};

  /// Named global widget contexts for cross-page inclusion.
  ///
  /// Widgets with a [EasySEOBaseWrapper.globalName] register their
  /// [BuildContext] here during [State.initState]. When generating a page,
  /// the manager can pull these globals into the output even though they
  /// are rendered outside the current page's widget tree.
  Map<String, BuildContext> get globals => _globals;

  // ------ EasySEO widget registry ----------
  // The stack of registered controllers
  // Using splay tree to sort depth of EasySEOPage controllers
  // so that it does not rely on mounting order.
  final _stack = SplayTreeMap<SeoRouteKey, EasySEOPageController>((key1, key2) => key1.compareTo(key2));

  /// Returns the controller that currently has authority (the deepest/newest one)
  EasySEOPageController? get _activeController => _stack.values.lastOrNull;

  /// Registers a page controller under a [SeoRouteKey].
  ///
  /// Returns `true` if the registration succeeded, or `false` if the key is
  /// already taken by a **different** controller (conflict). When the key is
  /// already held by the **same** controller the request is accepted.
  ///
  /// During registration the path is parsed; if it matches a dynamic pattern
  /// (see [shouldGather]) it is added to the gathered-pages set so it appears
  /// in the sitemap.
  @visibleForTesting
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

  void _unregister(SeoRouteKey key, EasySEOPageController controller) {
    if (_stack[key] != controller) return;
    debugPrint('🗑️ [EasySEO] Unregistering controller: $key, ${_stack.length}');
    _stack.remove(key);
  }

  /// Global trigger for the headless test or automated syncs
  Future<EasySEOGenerationResult> generateActive({SEORenderMode? mode}) async {
    debugPrint('🗑️ [EasySEO] generateActive() for: ${_stack.keys.lastOrNull ?? "unknown"}');
    final controller = _activeController;
    if (controller == null) return SeoSkipped("No active EasySEO controller found in registry.");
    return await controller.generate(mode: mode);
  }

  bool seoPageIsReady() {
    // TODO sealed bool class
    final controller = _activeController;
    if (controller == null) {
      debugPrint('⚠️ No active EasySEO controller found in registry.');
      return true;
    }
    return controller.isReady();
  }

  /// Clears the registry, gathered pages, and interactive-minimized state.
  ///
  /// Called between test cases to reset the manager to a clean state.
  @visibleForTesting
  void clear() {
    _stack.clear();
    _gatheredPages.clear();
    _interactiveMinimized = false;
  }

  /// Checks whether [pagePath] matches any registered dynamic path pattern.
  ///
  /// Dynamic patterns are extracted from [pages] during [init] (routes
  /// containing `:`, e.g. `products/:id`). Returns `true` if the path
  /// matches at least one pattern via [URLHelper.isPathMatch].
  @visibleForTesting
  bool shouldGather(String pagePath) {
    return _dynamicPathPatterns.any((pattern) => URLHelper().isPathMatch(pagePath, pattern));
  }

  /// Manually adds a dynamic route path to the gathered-pages set.
  ///
  /// The path is normalised (leading `/` added, `/` → `''`) before insertion
  /// into the set. Gathered pages appear in [getAllRoutes] and the sitemap.
  @visibleForTesting
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
  void _gatherFromHtml(String html) {
    final hrefRegex = RegExp(r'href="([^"]+)"');
    final matches = hrefRegex.allMatches(html);

    String? basePath;
    if (_baseUrl != null) {
      final baseUri = Uri.tryParse(_baseUrl!);
      basePath = (baseUri != null && baseUri.path != '/') ? baseUri.path : null;
    }

    for (final match in matches) {
      final href = match.group(1);
      if (href != null && href.isNotEmpty) {
        final uri = Uri.tryParse(href);
        if (uri != null) {
          String path = uri.path;
          if (basePath != null && path.startsWith(basePath)) {
            path = path.substring(basePath.length);
            if (!path.startsWith('/')) path = '/$path';
          }
          final parsed = parsePath(path);
          if (shouldGather(parsed.pagePath)) {
            addGatheredPage(path);
          }
        }
      }
    }
  }
  /// Returns the current active path using a layered fallback strategy:
  /// 1. [pathProvider] — explicit user-configured delegate (GoRouter, auto_route, Beamer).
  /// 2. [ModalRoute.of(context)?.settings.name] — works for Navigator 1.0 (vanilla, fluro).
  /// 3. [URLHelper().getCurrentPath()] — browser URL on web, empty string on native.
  String _getCurrentPath(BuildContext context) {
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
    bool showHighlights = false,
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
    this.showHighlights.value = showHighlights;
    if (renderMode != null) this.renderMode.value = renderMode;
    this.onGenerate = onGenerate;
    _baseUrl = baseUrl;
    _supportedLanguages = supportedLanguages;
    _headTags = headTags;
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

    _pages = staticPages;
    _dynamicPathPatterns = extractedDynamicPatterns;
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

  /// Builds an absolute URL from a relative [path].
  ///
  /// If [baseUrl] is not set, falls back to [PlatformHelper.host] and
  /// [PlatformHelper.protocol] for the domain. When all sources are empty
  /// the [path] is returned unchanged.
  ///
  /// The path is lower-cased and URI-encoded segment by segment to produce
  /// a clean, slash-joined absolute URL without a trailing slash.
  String formatFullUrl(String path) {
    String? bUrl = _baseUrl;
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
    final String? firstLang = _supportedLanguages.firstOrNull;
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
    final languages = UnmodifiableListView(_supportedLanguages);
    final List<String> rawPages = _pages.isEmpty ? [''] : _pages;

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
    final baseUrl = _baseUrl;
    if (baseUrl == null || baseUrl.isEmpty) return '';

    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final languages = UnmodifiableListView(_supportedLanguages);
    final List<String> rawPages = _pages.isEmpty ? [''] : _pages;

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
  String _getEffectiveCleanBaseUrl() {
    String? bUrl = _baseUrl;
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
  @visibleForTesting
  ({String pagePath, String? detectedLang}) parsePath(String path) {
    final cleanPath = path.trim();
    // Split the path to check segments
    final segments = cleanPath.split('/').where((s) => s.isNotEmpty).toList();

    String? detectedLang;
    List<String> pageSegments = segments;
    if (segments.isNotEmpty && _supportedLanguages.contains(segments.first)) {
      detectedLang = segments.first;
      pageSegments = segments.sublist(1);
    }

    final pagePath = pageSegments.isEmpty ? '' : '/${pageSegments.join('/')}';
    return (pagePath: pagePath, detectedLang: detectedLang);
  }

  /// Unified resolver that takes any path, parses it, and returns the canonical, alternate, and x-default URLs
  @visibleForTesting
  EasySEOUrls resolveSeoUrls(String path) {
    final parsed = parsePath(path.toLowerCase());
    final pagePath = parsed.pagePath;
    final detectedLang = parsed.detectedLang;
    final cleanBase = _getEffectiveCleanBaseUrl();

    // Canonical language defaults to the first supported language if none is detected.
    final canonicalLang = detectedLang ?? _supportedLanguages.firstOrNull;
    final canonicalUrl = _getUrlForLang(canonicalLang, pagePath, cleanBase: cleanBase);

    final Map<String, String> alternateUrls = {};
    for (final lang in _supportedLanguages) {
      alternateUrls[lang] = _getUrlForLang(lang, pagePath, cleanBase: cleanBase);
    }

    String? xDefaultUrl;
    final firstLang = _supportedLanguages.firstOrNull;
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

/// Holds the resolved set of canonical, alternate-language, and x-default URLs
/// for a single page, as produced by [EasySEOManager.resolveSeoUrls].
class EasySEOUrls {
  /// The canonical (primary) URL for this page.
  final String canonicalUrl;

  /// Map of language code → alternate URL for every [EasySEOManager.supportedLanguages].
  final Map<String, String> alternateUrls;

  /// The `x-default` fallback URL (typically maps to the first language).
  final String? xDefaultUrl;

  const EasySEOUrls({
    required this.canonicalUrl,
    required this.alternateUrls,
    this.xDefaultUrl,
  });
}

class _PanelPositioner extends StatefulWidget {
  final Widget defaultChild;
  final Widget customChild;

  const _PanelPositioner({
    required this.defaultChild,
    required this.customChild,
  });

  @override
  State<_PanelPositioner> createState() => _PanelPositionerState();
}

class _PanelPositionerState extends State<_PanelPositioner> {
  final manager = EasySEOManager.instance;

  @override
  void initState() {
    super.initState();
    manager._panelPosition.addListener(_onChanged);
    manager._panelSize.addListener(_onChanged);
  }

  @override
  void dispose() {
    manager._panelPosition.removeListener(_onChanged);
    manager._panelSize.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    manager._reclampPanelPosition(MediaQuery.of(context).size);
  }

  @override
  Widget build(BuildContext context) {
    final position = manager._panelPosition.value;
    if (position == null) {
      return Positioned(left: 0, right: 0, bottom: 16, child: widget.defaultChild);
    }
    final screen = MediaQuery.of(context).size;
    final size = manager._panelSize.value;
    final clampW = (size?.width ?? 56).clamp(56, screen.width);
    final clampH = (size?.height ?? 56).clamp(56, screen.height);
    final clamped = Offset(
      position.dx.clamp(0, screen.width - clampW),
      position.dy.clamp(0, screen.height - clampH),
    );
    return Positioned(left: clamped.dx, top: clamped.dy, child: widget.customChild);
  }
}
