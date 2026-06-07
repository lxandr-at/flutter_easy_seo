part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOFigureWrapper extends BaseSEOWrapper {
  const SEOFigureWrapper({
    super.key,
    required super.child,
    String? caption,
    super.className,
    super.attributes,
    super.globalName,
    super.additionalTags,
  }) : _caption = caption;

  final String? _caption;

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return _buildSimpleTag(tag: 'figure', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOFigureWrapperState();
}

class _SEOFigureWrapperState extends BaseSEOWrapperState<SEOFigureWrapper> {}
