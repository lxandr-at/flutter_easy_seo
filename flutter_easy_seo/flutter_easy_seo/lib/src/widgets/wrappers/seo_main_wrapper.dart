part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOMainWrapper extends BaseSEOWrapper {
  const SEOMainWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.additionalTags,
  });

  @override
  String get tagName => 'main';

  @override
  State<StatefulWidget> createState() => _SEOMainWrapperState();
}

class _SEOMainWrapperState extends BaseSEOWrapperState<SEOMainWrapper> {}
