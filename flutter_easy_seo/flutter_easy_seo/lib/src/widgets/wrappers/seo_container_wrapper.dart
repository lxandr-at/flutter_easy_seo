part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOContainerWrapper extends BaseSEOWrapper {
  const SEOContainerWrapper({
    super.key,
    required super.child,
    String tag = 'div',
    super.className,
    super.attributes,
    super.additionalTags,
  }) : _tag = tag;

  final String _tag;

  @override
  String get tagName => _tag;

  @override
  State<StatefulWidget> createState() => _SEOContainerWrapperState();
}

class _SEOContainerWrapperState extends BaseSEOWrapperState<SEOContainerWrapper> {}
