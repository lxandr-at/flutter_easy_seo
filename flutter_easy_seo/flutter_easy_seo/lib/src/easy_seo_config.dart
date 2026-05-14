part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

typedef EasySEOGenerationResult = ({
  String fullHtml,
  String currentLanguage,
  String path,
  String headContent,
  String bodyContent,
});

typedef EasySEOOnGenerateCallback = void Function(EasySEOGenerationResult generatedData);

/// Private registry entry type
typedef _SeoRegistryEntry = ({String path, EasySEOController controller});

class EasySEOConfig {
  // singleton
  EasySEOConfig._internal();
  static final EasySEOConfig _instance = EasySEOConfig._internal();
  static EasySEOConfig get instance => _instance;

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
  EasySEOController? get activeController => _stack.lastOrNull?.controller;
  /// Returns the path associated with the currently active SEO widget
  String? get currentPath => _stack.lastOrNull?.path;

  void register(String path, EasySEOController controller) {
    debugPrint('📦 [EasySEO] Registering: $path');
    _stack.add((path: path, controller: controller));
  }

  void unregister(EasySEOController controller) {
    debugPrint('🗑️ [EasySEO] Unregistering controller');
    _stack.removeWhere((entry) => entry.controller == controller);
  }

  /// Global trigger for the headless test or automated syncs
  Future<EasySEOGenerationResult?> generateActive() async {
    final controller = activeController;
    if (controller == null) {
      debugPrint('⚠️ No active EasySEO controller found in registry.');
      return null;
    }
    return await controller.generate();
  }

  bool seoPageIsReady() {
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
}
