part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOFigureWrapper extends BaseSEOWrapper {
  const SEOFigureWrapper({
    super.key,
    required Widget child,
    String? caption,
    String? className,
    Map<String, String>? attributes,
  }) : _caption = caption, super(child: child, className: className, attributes: attributes);

  final String? _caption;

  @override
  String get tagName => 'figure';
}