import 'package:flutter_easy_seo/flutter_easy_seo.dart';

mixin URLHelperBase {
  /// Platform-specific implementation to get the raw URL
  String? get rawCurrentUrl;

  /// Platform-specific implementation to get the raw path
  String get rawCurrentPath;

  /// Returns the current full URL, respecting [EasySEOManager.baseUrl] if set.
  String? getCurrentUrl() {
    final path = getCurrentPath();
    return EasySEOManager.instance.resolveSeoUrls(path).canonicalUrl;
  }

  /// Returns the current path (pathname).
  String getCurrentPath() => rawCurrentPath;

  /// Returns a map of language code to full URL for all supported languages.
  Map<String, String> getAlternateUrls({String? pathOverride}) {
    final path = pathOverride ?? getCurrentPath();
    return EasySEOManager.instance.resolveSeoUrls(path).alternateUrls;
  }
}
