part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOImageWrapper extends BaseSEOWrapper {
  final String? alt;
  final String? src;

  const SEOImageWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    this.alt,
    this.src,
  });

  @override
  String get tagName => "img";

  @override
  Map<String, String> get additionalAttributes => {
    if (src != null) 'src': src!,
    if (alt != null) 'alt': alt!,
  };
}