part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOFigureWrapper extends BaseSEOWrapper {
  const SEOFigureWrapper({
    super.key,
    required super.child,
    String? caption,
    super.className,
    super.attributes,
    super.additionalTags,
  }) : _caption = caption;

  final String? _caption;

  @override
  String get tagName => 'figure';

  @override
  State<StatefulWidget> createState() => _SEOFigureWrapperState();
}

class _SEOFigureWrapperState extends BaseSEOWrapperState<SEOFigureWrapper> {}
