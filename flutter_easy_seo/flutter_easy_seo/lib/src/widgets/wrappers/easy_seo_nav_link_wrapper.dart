part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEONavLinkWrapper extends EasySEOLinkWrapper {
  const EasySEONavLinkWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
    required super.path,
    super.text,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return SEOHtml.li(children: [
      super.toSEOHtml(children: children, navItems: navItems, context: context),
    ]);
  }

  @override
  State<StatefulWidget> createState() => _EasySEONavLinkWrapperState();
}

class _EasySEONavLinkWrapperState extends EasySEOBaseWrapperState<EasySEONavLinkWrapper> {}
