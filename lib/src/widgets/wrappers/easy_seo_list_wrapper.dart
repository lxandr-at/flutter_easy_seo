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

  static List<SEOHtml> _unwrap(List<SEOHtml> items) {
    final result = <SEOHtml>[];
    for (final item in items) {
      if (item.tag.isEmpty && item.jsonLd == null) {
        result.addAll(_unwrap(item.children));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    final flat = _unwrap(children);
    final enrichedChildren = flat.asMap().entries.map((entry) {
      final child = entry.value;
      if (child.tag == 'li' && child.jsonLd != null) {
        return SEOHtml(
          tag: 'li',
          attributes: child.attributes,
          jsonLd: {...child.jsonLd!, 'position': entry.key + 1},
          children: child.children,
          content: child.content,
        );
      }
      return child;
    }).toList();

    final itemCount = enrichedChildren.where((c) => c.tag == 'li').length;

    return SEOHtml(
      tag: 'ul',
      jsonLd: {
        '@type': 'ItemList',
        if (itemCount > 0) 'numberOfItems': itemCount,
      },
      children: enrichedChildren,
    );
  }

  @override
  State<StatefulWidget> createState() => _EasySEOListWrapperState();
}

class _EasySEOListWrapperState extends EasySEOBaseWrapperState<EasySEOListWrapper> {}
