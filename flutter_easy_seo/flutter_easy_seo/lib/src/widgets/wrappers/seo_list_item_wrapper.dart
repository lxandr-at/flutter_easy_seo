part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOListItemWrapper extends BaseSEOWrapper {
  const SEOListItemWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.additionalTags,
  });

  @override
  String get tagName => 'li';

  @override
  State<StatefulWidget> createState() => _SEOListItemWrapperState();
}

class _SEOListItemWrapperState extends BaseSEOWrapperState<SEOListItemWrapper> {}
