part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Produces `<li><a>` pairs for use inside [EasySEONavWrapper].
///
/// Must be used as a child of [EasySEONavWrapper] to form a valid
/// navigation structure. Each instance contributes both the visual `<a>` tag
/// (via [EasySEOLinkWrapper.toSEOHtml]) and registers an [SEONavItem] during
/// tree traversal, which the parent [EasySEONavWrapper] collects for JSON-LD
/// generation.
///
/// Using this wrapper outside of [EasySEONavWrapper] will produce orphaned
/// `<li>` elements without a containing `<ul>` or `<ol>`.
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
    return SEOListItem(
      children: [
        super.toSEOHtml(children: children, navItems: navItems, context: context),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _EasySeoNavAnchorWrapperState();
}

class _EasySeoNavAnchorWrapperState extends EasySEOBaseWrapperState<EasySeoNavAnchorWrapper> {}
