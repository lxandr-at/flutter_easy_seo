part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOSectionWrapper extends BaseSEOWrapper {
  const SEOSectionWrapper({
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
    return _buildSimpleTag(tag: 'section', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOSectionWrapperState();
}

class _SEOSectionWrapperState extends BaseSEOWrapperState<SEOSectionWrapper> {}
