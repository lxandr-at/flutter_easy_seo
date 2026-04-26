part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOFormWrapper extends BaseSEOWrapper {
  const SEOFormWrapper({
    super.key,
    required Widget child,
    String? className,
    Map<String, String>? attributes,
  }) : super(child: child, className: className, attributes: attributes);

  @override
  String get tagName => 'form';
}