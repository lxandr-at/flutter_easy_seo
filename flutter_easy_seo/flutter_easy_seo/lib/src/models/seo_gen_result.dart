part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

@immutable
sealed class EasySEOGenerationResult {
  const EasySEOGenerationResult();
}

/// The "Success" state containing the complex data you previously had in your typedef.
class SeoSuccess extends EasySEOGenerationResult {
  final String fullHtml;
  final String currentLanguage;
  final String path;
  final String headContent;
  final String bodyContent;

  const SeoSuccess({
    required this.fullHtml,
    required this.currentLanguage,
    required this.path,
    required this.headContent,
    required this.bodyContent,
  });
}

/// Use this when generation is skipped (e.g., globally disabled or route excluded).
class SeoSkipped extends EasySEOGenerationResult {
  final String reason;
  const SeoSkipped(this.reason);
}

/// Use this if the expected root element (like a specific Key or ID) was not found.
class SeoMissingRoot extends EasySEOGenerationResult {
  final String message;
  const SeoMissingRoot(this.message);
}

/// Catch-all for unexpected exceptions during the generation process.
class SeoFailure extends EasySEOGenerationResult {
  final Object error;
  final StackTrace? stackTrace;
  const SeoFailure(this.error, [this.stackTrace]);
}