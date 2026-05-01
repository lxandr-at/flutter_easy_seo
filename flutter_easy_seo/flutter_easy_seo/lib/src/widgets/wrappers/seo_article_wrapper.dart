part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOArticleWrapper extends BaseSEOWrapper {
  const SEOArticleWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName
  });

  @override
  String get tagName => 'article';

  @override
  State<StatefulWidget> createState() => _SEOArticleWrapperState();
}

class _SEOArticleWrapperState extends BaseSEOWrapperState<SEOArticleWrapper> {}