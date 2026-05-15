part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

typedef EasySEOOnGenerateCallback = void Function(EasySEOGenerationResult generatedData);

/// Private registry entry type
typedef _SeoRegistryEntry = ({String path, EasySEOPageController controller});

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

  String? baseUrl;
  SEOServiceInfo? serviceInfo;
  List<String> supportedLanguages = const [];
  List<String> pages = const [];
  List<EasySEOHeadTag> headTags = const [];

  EasySEOOnGenerateCallback? onGenerate;

  /// Optional provider to get the current path from the context (e.g. from GoRouter)
  String? Function(BuildContext)? pathProvider;

  /// Optional provider to get the current full URL from the context
  String? Function(BuildContext)? urlProvider;

  // This is now directly accessible via EasySEOConfig.instance.globals
  final Map<String, BuildContext> globals = {};

  // ------ EasySEO widget registry ----------
  // The stack of registered controllers
  final List<_SeoRegistryEntry> _stack = [];
  /// Returns the controller that currently has authority (the deepest/newest one)
  EasySEOPageController? get activeController => _stack.lastOrNull?.controller;
  /// Returns the path associated with the currently active SEO widget
  String? get currentPath => _stack.lastOrNull?.path;

  void register(String path, EasySEOPageController controller) {
    debugPrint('📦 [EasySEO] Registering: $path');
    _stack.add((path: path, controller: controller));
  }

  void unregister(EasySEOPageController controller) {
    debugPrint('🗑️ [EasySEO] Unregistering controller');
    _stack.removeWhere((entry) => entry.controller == controller);
  }

  /// Global trigger for the headless test or automated syncs
  Future<EasySEOGenerationResult> generateActive() async {
    final controller = activeController;
    if (controller == null) return SeoSkipped("No active EasySEO controller found in registry.");
    return await controller.generate();
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

  /// Internal cleanup for tests
  @visibleForTesting
  void clear() => _stack.clear();
  // ------ EasySEO widget registry ----------

  /// Initialize the settings.
  /// You can call this via EasySEOConfig.instance.init(...)
  void init({
    bool enabled = true,
    bool enableFileOutput = false,
    bool enableLiveOutput = false,
    bool disableOnGenerate = false,
    EasySEOOnGenerateCallback? onGenerate,
    String? baseUrl,
    SEOServiceInfo? serviceInfo,
    List<String> supportedLanguages = const [],
    List<String> pages = const [],
    List<EasySEOHeadTag> headTags = const [],
    String? Function(BuildContext)? pathProvider,
    String? Function(BuildContext)? urlProvider,
  }) {
    this.enabled.value = enabled;
    this.enableFileOutput.value = enableFileOutput;
    this.enableLiveOutput.value = enableLiveOutput;
    this.disableOnGenerate.value = disableOnGenerate;
    this.onGenerate = onGenerate;
    this.baseUrl = baseUrl;
    this.serviceInfo = serviceInfo;
    this.supportedLanguages = supportedLanguages;
    this.pages = pages;
    this.headTags = headTags;
    this.pathProvider = pathProvider;
    this.urlProvider = urlProvider;
  }

  /// Helper to check if any SEO output is active
  bool get isActive =>
      enableFileOutput.value || enableLiveOutput.value || !disableOnGenerate.value;

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

    final cleanBase =
        bUrl.endsWith('/') ? bUrl.substring(0, bUrl.length - 1) : bUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBase$cleanPath';
  }

  /// Helper to generate the correct relative path for a given language
  String _getUrlForLang(String? lang, String pagePath, {String cleanBase = ''}) {
    final String? firstLang = supportedLanguages.isNotEmpty ? supportedLanguages.first : null;
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
  List<String> getAllRoutes() {
    final languages = UnmodifiableListView(supportedLanguages);
    final List<String> rawPages = pages.isEmpty ? [''] : pages;
    
    final Set<String> uniqueCleanPages = {};
    for (final p in rawPages) {
      String cp = p.trim();
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
      String cp = p.trim();
      if (cp.isNotEmpty && !cp.startsWith('/')) cp = '/$cp';
      if (cp == '/') cp = '';
      uniqueCleanPages.add(cp);
    }

    final StringBuffer sitemap = StringBuffer();
    sitemap.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sitemap.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"');
    sitemap.writeln('        xmlns:xhtml="http://www.w3.org/1999/xhtml">');

    final String? firstLang = languages.isNotEmpty ? languages.first : null;

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
}
