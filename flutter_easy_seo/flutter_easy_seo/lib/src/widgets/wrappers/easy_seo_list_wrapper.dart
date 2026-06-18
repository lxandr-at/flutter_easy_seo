part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOListWrapper extends EasySEOBaseWrapper {
  const EasySEOListWrapper({
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
    return SEOHtml(tag: 'ul', children: children);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOListWrapperState();
}

class _EasySEOListWrapperState extends EasySEOBaseWrapperState<EasySEOListWrapper> {}
