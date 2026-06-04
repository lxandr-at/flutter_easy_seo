part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOCustomWrapper extends BaseSEOWrapper {
  final Widget Function(BuildContext, Widget)? builder;
  final String? tag;

  const SEOCustomWrapper({
    super.key,
    required super.child,
    this.builder,
    this.tag,
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
    return _buildSimpleTag(tag: tag ?? 'div', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOCustomWrapperState();
}

class _SEOCustomWrapperState extends BaseSEOWrapperState<SEOCustomWrapper> {}
