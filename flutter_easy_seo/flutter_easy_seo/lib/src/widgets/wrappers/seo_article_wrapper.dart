part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOArticleWrapper extends BaseSEOWrapper {
  const SEOArticleWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.additionalTags,
    super.jsonLd,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return _buildSimpleTag(tag: 'article', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOArticleWrapperState();
}

class _SEOArticleWrapperState extends BaseSEOWrapperState<SEOArticleWrapper> {}
