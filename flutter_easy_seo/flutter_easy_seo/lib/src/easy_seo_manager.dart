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
  final ValueNotifier<SEORenderMode> renderMode = ValueNotifier(SEORenderMode.full);
  bool interactiveMinimized = false;

  String? baseUrl;
  SEOServiceInfo? serviceInfo;
  List<String> supportedLanguages = const [];
  List<String> pages = const [];
  List<EasySEOHeadTag> headTags = const [];
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

  void register(SeoRouteKey key, EasySEOPageController controller) {
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
  }

  void unregister(SeoRouteKey key) {
    debugPrint('🗑️ [EasySEO] Unregistering controller: $key, ${_stack.length}');
    _stack.remove(key);
    debugPrint('🗑️ [EasySEO] Unregistering controller: $key, ${_stack.length}');
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
  /// Returns the current active path, prioritizing the pathProvider with the given [context]
  /// and falling back to URLHelper's current browser path.
  String getCurrentPath(BuildContext context) {
    if (pathProvider != null) {
      final path = pathProvider!(context);
      if (path != null) return path;
    }
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
    SEOServiceInfo? serviceInfo,
    List<String> supportedLanguages = const [],
    List<String> pages = const [],
    List<EasySEOHeadTag> headTags = const [],
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
    this.serviceInfo = serviceInfo;
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
    this.dynamicPathPatterns = extractedDynamicPatterns;
  }

  /// Helper to check if any SEO output is active
  bool get isActive => enableFileOutput.value || enableLiveOutput.value || !disableOnGenerate.value;

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
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBase$cleanPath';
  }

  /// Helper to generate the correct relative path for a given language
  String _getUrlForLang(String? lang, String pagePath, {String cleanBase = ''}) {
    final String? firstLang = supportedLanguages.firstOrNull;
    final targetLang = lang ?? firstLang;

    // Root case: if it's the first language and root path, omit the prefix
    if (pagePath.isEmpty && targetLang == firstLang) {
      return '$cleanBase/';
    }

    // All other cases (subpages or non-primary languages) use the prefix
    if (targetLang != null) {
      return '$cleanBase/$targetLang$pagePath';
    }

    // Fallback for neutral subpages (shouldn't normally happen with exhaustive langs)
    return pagePath.isEmpty ? '$cleanBase/' : '$cleanBase$pagePath';
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

    final pagePath = pageSegments.isEmpty ? '' : '/' + pageSegments.join('/');
    return (pagePath: pagePath, detectedLang: detectedLang);
  }

  /// Unified resolver that takes any path, parses it, and returns the canonical, alternate, and x-default URLs
  EasySEOUrls resolveSeoUrls(String path) {
    final parsed = parsePath(path);
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
