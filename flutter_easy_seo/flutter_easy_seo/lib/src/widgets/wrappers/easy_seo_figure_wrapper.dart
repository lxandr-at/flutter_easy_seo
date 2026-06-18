part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOFigureWrapper extends EasySEOBaseWrapper {
  const EasySEOFigureWrapper({
    super.key,
    required super.child,
    String? caption,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
  }) : _caption = caption;

  final String? _caption;

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    final allChildren = [
      ...children,
      if (_caption != null) SEOFigcaption(content: _caption),
    ];
    return SEOHtml(tag: 'figure', children: allChildren);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOFigureWrapperState();
}

class _EasySEOFigureWrapperState extends EasySEOBaseWrapperState<EasySEOFigureWrapper> {}
