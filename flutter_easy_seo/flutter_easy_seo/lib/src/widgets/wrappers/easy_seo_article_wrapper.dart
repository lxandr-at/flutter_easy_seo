part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOArticleWrapper extends EasySEOBaseWrapper {
  const EasySEOArticleWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
    super.jsonLd,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return SEOHtml(tag: 'article', children: children);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOArticleWrapperState();
}

class _EasySEOArticleWrapperState extends EasySEOBaseWrapperState<EasySEOArticleWrapper> {}
