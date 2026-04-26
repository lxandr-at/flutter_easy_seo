part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOSectionWrapper extends BaseSEOWrapper {
  const SEOSectionWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
  });

  @override
  String get tagName => 'section';
}