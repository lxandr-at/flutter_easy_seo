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
    return SEOHeader(h1: h1, p: p, children: children);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOHeaderWrapperState();
}

class _EasySEOHeaderWrapperState extends EasySEOBaseWrapperState<EasySEOHeaderWrapper> {}
