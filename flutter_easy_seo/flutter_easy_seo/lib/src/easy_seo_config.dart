part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOConfig {
  // 1. Private constructor
  EasySEOConfig._();

  // 2. The single instance
  static final EasySEOConfig _instance = EasySEOConfig._();

  // 3. The 'instance' getter
  static EasySEOConfig get instance => _instance;

  // --- Instance Properties ---

  // ValueNotifiers are now instance-level, accessible via EasySEOConfig.instance
  final ValueNotifier<bool> enabled = ValueNotifier(true);
  final ValueNotifier<bool> enableFileOutput = ValueNotifier(false);
  final ValueNotifier<bool> enableLiveOutput = ValueNotifier(false);

  String baseUrl = "";

  // This is now directly accessible via EasySEOConfig.instance.globals
  final Map<String, BuildContext> globals = {};

  /// Initialize the settings.
  /// You can call this via EasySEOConfig.instance.init(...)
  void init({
    bool enabled = true,
    bool enableFileOutput = false,
    bool enableLiveOutput = false,
    String baseUrl = "",
  }) {
    this.enabled.value = enabled;
    this.enableFileOutput.value = enableFileOutput;
    this.enableLiveOutput.value = enableLiveOutput;
    this.baseUrl = baseUrl;
  }

  /// Helper to check if any SEO output is active
  bool get isActive => enableFileOutput.value || enableLiveOutput.value;
}
