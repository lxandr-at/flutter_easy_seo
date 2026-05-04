part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOHeaderWrapper extends BaseSEOWrapper {
  const SEOHeaderWrapper({
    super.key,
    required super.child,
    this.h1,
    this.p,
    super.className,
    super.attributes,
    super.additionalTags,
  });

  final String? h1;
  final String? p;

  @override
  String get tagName => 'header';

  @override
  List<SEOHtml> get additionalTags {
    final tags = <SEOHtml>[...super.additionalTags];
    if (p != null) tags.insert(0, SEOHtml.p(p!));
    if (h1 != null) tags.insert(0, SEOHtml.h1(h1!));
    return tags;
  }

  @override
  State<StatefulWidget> createState() => _SEOHeaderWrapperState();
}

class _SEOHeaderWrapperState extends BaseSEOWrapperState<SEOHeaderWrapper> {}
