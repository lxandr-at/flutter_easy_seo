part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEONavWrapper extends EasySEOBaseWrapper {
  final bool isBreadcrumb;

  const EasySEONavWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.additionalTags,
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
          modifiedChildren.add(const SEOHtml.span(
            '›',
            attributes: {'aria-hidden': 'true', 'style': 'margin: 0 8px;'},
          ));
        }
      }

      final navAttrs = _buildAttributes() ?? <String, String>{};
      navAttrs['aria-label'] = 'Breadcrumb';

      return SEOHtml.nav(
        attributes: navAttrs,
        jsonLd: navItems.isNotEmpty ? SEOHtmlJsonLd.breadcrumbListData(navItems) : null,
        children: [
          SEOHtml(
            tag: 'ol',
            attributes: {
              'style': 'display: flex; list-style: none; padding: 0;',
            },
            children: modifiedChildren,
          ),
        ],
      );
    }

    return SEOHtml.nav(
      attributes: _buildAttributes(),
      jsonLd: navItems.isNotEmpty
          ? SEOHtmlJsonLd.siteNavigationData(navItems)
          : null,
      children: [
        SEOHtml.ul(children: children),
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
