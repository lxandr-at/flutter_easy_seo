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
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return _buildSimpleTag(tag: 'form', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOFormWrapperState();
}

class _SEOFormWrapperState extends BaseSEOWrapperState<SEOFormWrapper> {}
