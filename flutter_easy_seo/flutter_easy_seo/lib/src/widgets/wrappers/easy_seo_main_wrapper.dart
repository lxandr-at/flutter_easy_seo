part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOMainWrapper extends EasySEOBaseWrapper {
  const EasySEOMainWrapper({
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
    return SEOHtml(tag: 'main', children: children);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOMainWrapperState();
}

class _EasySEOMainWrapperState extends EasySEOBaseWrapperState<EasySEOMainWrapper> {}
