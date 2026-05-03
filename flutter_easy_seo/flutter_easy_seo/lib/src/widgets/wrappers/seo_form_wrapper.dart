part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOFormWrapper extends BaseSEOWrapper {
  const SEOFormWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.additionalTags,
  });

  @override
  String get tagName => 'form';

  @override
  State<StatefulWidget> createState() => _SEOFormWrapperState();
}

class _SEOFormWrapperState extends BaseSEOWrapperState<SEOFormWrapper> {}
