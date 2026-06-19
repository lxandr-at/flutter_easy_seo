part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySeoNavAnchorWrapper extends EasySEOLinkWrapper {
  const EasySeoNavAnchorWrapper({
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
    return SEOListItem(children: [
      super.toSEOHtml(children: children, navItems: navItems, context: context),
    ]);
  }

  @override
  State<StatefulWidget> createState() => _EasySeoNavAnchorWrapperState();
}

class _EasySeoNavAnchorWrapperState extends EasySEOBaseWrapperState<EasySeoNavAnchorWrapper> {}
