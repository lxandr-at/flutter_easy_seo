part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOHeaderWrapper extends BaseSEOWrapper {
  const SEOHeaderWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.additionalTags,
  });

  @override
  String get tagName => 'header';

  @override
  State<StatefulWidget> createState() => _SEOHeaderWrapperState();
}

class _SEOHeaderWrapperState extends BaseSEOWrapperState<SEOHeaderWrapper> {}
