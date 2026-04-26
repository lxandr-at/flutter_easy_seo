part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOArticleWrapper extends BaseSEOWrapper {
  const SEOArticleWrapper({
    super.key,
    required Widget child,
    String? className,
    Map<String, String>? attributes,
  }) : super(child: child, className: className, attributes: attributes);

  @override
  String get tagName => 'article';
}