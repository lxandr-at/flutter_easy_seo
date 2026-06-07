part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOMainWrapper extends BaseSEOWrapper {
  const SEOMainWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.additionalTags,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return _buildSimpleTag(tag: 'main', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOMainWrapperState();
}

class _SEOMainWrapperState extends BaseSEOWrapperState<SEOMainWrapper> {}
