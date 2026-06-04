part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEONavWrapper extends BaseSEOWrapper {
  final String? label;
  final bool isBreadcrumb;

  const SEONavWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.additionalTags,
    this.label,
    this.isBreadcrumb = false,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    final allChildren = <SEOHtml>[
      SEOHtml.ul(children: children),
    ];
    if (navItems.isNotEmpty) {
      allChildren.add(isBreadcrumb
          ? SEOHtmlJsonLd.breadcrumbList(navItems)
          : SEOHtmlJsonLd.siteNavigation(navItems));
    }
    return SEOHtml.nav(
      attributes: _buildAttributes(),
      children: allChildren,
    );
  }

  @override
  State<StatefulWidget> createState() => _SEONavWrapperState();
}

class _SEONavWrapperState extends BaseSEOWrapperState<SEONavWrapper> {}
