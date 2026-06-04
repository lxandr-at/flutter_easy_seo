part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOAsideWrapper extends BaseSEOWrapper {
  const SEOAsideWrapper({
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
    return _buildSimpleTag(tag: 'aside', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOAsideWrapperState();
}

class _SEOAsideWrapperState extends BaseSEOWrapperState<SEOAsideWrapper> {}
