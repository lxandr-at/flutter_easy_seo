part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOAsideWrapper extends BaseSEOWrapper {
  const SEOAsideWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName
  });

  @override
  String get tagName => 'aside';

  @override
  State<StatefulWidget> createState() => _SEOAsideWrapperState();
}

class _SEOAsideWrapperState extends BaseSEOWrapperState<SEOAsideWrapper> {}