part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOConfig {
  EasySEOConfig._();

  // We use ValueNotifiers so the UI or Logic can listen for changes
  static final ValueNotifier<bool> enableFileOutput = ValueNotifier(false);
  static final ValueNotifier<bool> enableLiveOutput = ValueNotifier(false);

  // Base URL usually doesn't change at runtime, so a standard variable is fine
  static String baseUrl = "";

  /// Initialize the settings.
  static void init({
    bool enableFileOutput = false,
    bool enableLiveOutput = false,
    String baseUrl = "",
  }) {
    EasySEOConfig.enableFileOutput.value = enableFileOutput;
    EasySEOConfig.enableLiveOutput.value = enableLiveOutput;
    EasySEOConfig.baseUrl = baseUrl;
  }

  /// Helper to check if any SEO output is active
  static bool get isActive => enableFileOutput.value || enableLiveOutput.value;
}