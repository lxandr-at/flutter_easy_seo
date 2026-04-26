part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

enum SEOTextType { h1, h2, h3, h4, h5, h6, p }

class SEOTextWrapper extends BaseSEOWrapper {
  const SEOTextWrapper({
    super.key,
    required super.child,
    this.textType = SEOTextType.p,
    super.className,
    super.attributes,
  });

  final SEOTextType textType;

  @override
  String get tagName => textType.name;
}