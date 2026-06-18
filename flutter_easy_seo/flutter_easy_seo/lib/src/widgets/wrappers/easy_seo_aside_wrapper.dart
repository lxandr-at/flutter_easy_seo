part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOAsideWrapper extends EasySEOBaseWrapper {
  const EasySEOAsideWrapper({
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
    return SEOHtml(tag: 'aside', children: children);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOAsideWrapperState();
}

class _EasySEOAsideWrapperState extends EasySEOBaseWrapperState<EasySEOAsideWrapper> {}
