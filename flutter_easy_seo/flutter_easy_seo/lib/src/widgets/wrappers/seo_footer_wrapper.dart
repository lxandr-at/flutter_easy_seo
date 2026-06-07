part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOFooterWrapper extends BaseSEOWrapper {
  const SEOFooterWrapper({
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
    return _buildSimpleTag(tag: 'footer', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOFooterWrapperState();
}

class _SEOFooterWrapperState extends BaseSEOWrapperState<SEOFooterWrapper> {}
