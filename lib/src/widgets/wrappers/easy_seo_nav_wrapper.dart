part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Wraps child widgets in a semantic `<nav>` element with JSON-LD structured
/// data for navigation or breadcrumbs.
///
/// This wrapper must be used together with [EasySeoNavAnchorWrapper]. Each
/// [EasySeoNavAnchorWrapper] child contributes a `<li><a>` pair to the
/// generated HTML and registers an [SEONavItem] that the traversal collects
/// and passes back to this wrapper for JSON-LD output.
///
/// **Standard navigation** (default, [isBreadcrumb] = `false`):
/// Renders `<nav><ul><li><a>...</a></li>...</ul></nav>` with
/// `SiteNavigationElement` JSON-LD.
///
/// **Breadcrumb navigation** ([isBreadcrumb] = `true`):
/// Renders `<nav aria-label="Breadcrumb"><ol><li><a>...</a> › </li>...</ol></nav>`
/// with `BreadcrumbList` JSON-LD and `aria-current="page"` on the final link.
class EasySEONavWrapper extends EasySEOBaseWrapper {
  /// When `true`, renders as a breadcrumb with ordered list, `›` separators,
  /// `aria-current="page"` on the last item and `BreadcrumbList` JSON-LD.
  /// When `false` (default), renders an unordered list with
  /// `SiteNavigationElement` JSON-LD.
  final bool isBreadcrumb;

  const EasySEONavWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
    this.isBreadcrumb = false,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    if (isBreadcrumb) {
      final flatItems = _flattenChildren(children);
      final modifiedChildren = <SEOHtml>[];
      final lastIndex = flatItems.length - 1;

      for (var i = 0; i < flatItems.length; i++) {
        if (i == lastIndex) {
          modifiedChildren.add(_addAriaCurrentToLink(flatItems[i]));
        } else {
          modifiedChildren.add(flatItems[i]);
          modifiedChildren.add(const SEOSpan(
            '›',
            attributes: {'aria-hidden': 'true', 'style': 'margin: 0 8px;'},
          ));
        }
      }

      return SEONav(
        attributes: {'aria-label': 'Breadcrumb'},
        jsonLd: navItems.isNotEmpty ? SEOHtmlJsonLd.breadcrumbListData(navItems) : null,
        children: [
          SEOOrderedList(
            attributes: {
              'style': 'display: flex; list-style: none; padding: 0;',
            },
            children: modifiedChildren,
          ),
        ],
      );
    }

    return SEONav(
      jsonLd: navItems.isNotEmpty
          ? SEOHtmlJsonLd.siteNavigationData(navItems)
          : null,
      children: [
        SEOUnorderedList(children: children),
      ],
    );
  }

  List<SEOHtml> _flattenChildren(List<SEOHtml> items) {
    final result = <SEOHtml>[];
    for (final item in items) {
      if (item.tag.isEmpty) {
        result.addAll(_flattenChildren(item.children));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  SEOHtml _addAriaCurrentToLink(SEOHtml li) {
    final modifiedChildren = li.children.map((child) {
      if (child.tag == 'a') {
        return SEOHtml(
          tag: 'a',
          content: child.content,
          children: child.children,
          attributes: {
            ...?child.attributes,
            'aria-current': 'page',
          },
          jsonLd: child.jsonLd,
          relativePath: child.relativePath,
        );
      }
      return child;
    }).toList();

    return SEOHtml(
      tag: li.tag,
      content: li.content,
      children: modifiedChildren,
      attributes: li.attributes,
      jsonLd: li.jsonLd,
      relativePath: li.relativePath,
    );
  }

  @override
  State<StatefulWidget> createState() => _EasySEONavWrapperState();
}

class _EasySEONavWrapperState extends EasySEOBaseWrapperState<EasySEONavWrapper> {}
