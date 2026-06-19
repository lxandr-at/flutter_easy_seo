part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOFooterWrapper extends EasySEOBaseWrapper {
  const EasySEOFooterWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return SEOFooter(children: children);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOFooterWrapperState();
}

class _EasySEOFooterWrapperState extends EasySEOBaseWrapperState<EasySEOFooterWrapper> {}
