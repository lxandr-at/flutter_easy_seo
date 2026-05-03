part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOListWrapper extends BaseSEOWrapper {
  const SEOListWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.additionalTags,
  });

  @override
  String get tagName => 'ul';

  @override
  State<StatefulWidget> createState() => _SEOListWrapperState();
}

class _SEOListWrapperState extends BaseSEOWrapperState<SEOListWrapper> {}
