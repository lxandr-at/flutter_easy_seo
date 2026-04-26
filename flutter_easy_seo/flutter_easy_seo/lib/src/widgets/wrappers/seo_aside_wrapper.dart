part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOAsideWrapper extends BaseSEOWrapper {
  const SEOAsideWrapper({
    super.key,
    required Widget child,
    String? className,
    Map<String, String>? attributes,
  }) : super(child: child, className: className, attributes: attributes);

  @override
  String get tagName => 'aside';
}