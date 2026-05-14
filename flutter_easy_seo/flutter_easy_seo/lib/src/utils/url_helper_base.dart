import 'package:flutter_easy_seo/flutter_easy_seo.dart';

mixin URLHelperBase {
  /// Platform-specific implementation to get the raw URL
  String? get rawCurrentUrl;

  /// Platform-specific implementation to get the raw path
  String get rawCurrentPath;

  /// Returns the current full URL, respecting [EasySEOConfig.baseUrl] if set.
  String? getCurrentUrl() {
    final baseUrl = EasySEOConfig.instance.baseUrl;
    if (baseUrl != null && baseUrl.isNotEmpty) {
      return EasySEOConfig.instance.formatFullUrl(getCurrentPath());
    }
    return rawCurrentUrl;
  }

  /// Returns the current path (pathname).
  String getCurrentPath() => rawCurrentPath;

  /// Returns a map of language code to full URL for all supported languages.
  Map<String, String> getAlternateUrls({String? pathOverride}) {
    final languages = EasySEOConfig.instance.supportedLanguages;
    if (languages.isEmpty) return {};

    final path = pathOverride ?? getCurrentPath();
    final baseUrl = EasySEOConfig.instance.baseUrl;
    if (baseUrl == null || baseUrl.isEmpty) return {};

    // Split the path to find and replace the language segment
    // We assume the language is the first segment: /de/offers -> ['', 'de', 'offers']
    final segments = path.split('/');

    Map<String, String> results = {};

    for (final lang in languages) {
      String alternatePath;
      if (segments.length > 1 && languages.contains(segments[1])) {
        // Replace the existing language segment
        final newSegments = List<String>.from(segments);
        newSegments[1] = lang;
        alternatePath = newSegments.join('/');
      } else {
        // Prepend the language segment if not found
        final baseContent = path.startsWith('/') ? path.substring(1) : path;
        alternatePath = '/$lang/$baseContent';
      }

      // Cleanup trailing slashes if any
      if (alternatePath.endsWith('/')) {
        alternatePath = alternatePath.substring(0, alternatePath.length - 1);
      }

      results[lang] = EasySEOConfig.instance.formatFullUrl(alternatePath);
    }

    return results;
  }
}
