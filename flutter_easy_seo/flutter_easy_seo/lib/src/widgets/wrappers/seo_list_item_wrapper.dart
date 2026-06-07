part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOListItemWrapper extends BaseSEOWrapper {
  const SEOListItemWrapper({
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
    return _buildSimpleTag(tag: 'li', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOListItemWrapperState();
}

class _SEOListItemWrapperState extends BaseSEOWrapperState<SEOListItemWrapper> {}
