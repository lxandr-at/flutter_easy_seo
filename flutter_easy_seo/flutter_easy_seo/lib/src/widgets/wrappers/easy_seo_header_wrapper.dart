part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOHeaderWrapper extends EasySEOBaseWrapper {
  const EasySEOHeaderWrapper({
    super.key,
    required super.child,
    this.h1,
    this.p,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
  });

  final String? h1;
  final String? p;

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    final allChildren = <SEOHtml>[...children];
    if (p != null) allChildren.insert(0, SEOHtml.p(p!));
    if (h1 != null) allChildren.insert(0, SEOHtml.h1(h1!));
    return _buildSimpleTag(tag: 'header', children: allChildren, context: context);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOHeaderWrapperState();
}

class _EasySEOHeaderWrapperState extends EasySEOBaseWrapperState<EasySEOHeaderWrapper> {}
