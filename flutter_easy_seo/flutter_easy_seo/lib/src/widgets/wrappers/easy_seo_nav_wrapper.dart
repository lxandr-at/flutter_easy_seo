part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEONavWrapper extends EasySEOBaseWrapper {
  final String? label;
  final bool isBreadcrumb;

  const EasySEONavWrapper({
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
    return SEOHtml.nav(
      attributes: _buildAttributes(),
      jsonLd: navItems.isNotEmpty
          ? (isBreadcrumb
              ? SEOHtmlJsonLd.breadcrumbListData(navItems)
              : SEOHtmlJsonLd.siteNavigationData(navItems))
          : null,
      children: [
        SEOHtml.ul(children: children),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _EasySEONavWrapperState();
}

class _EasySEONavWrapperState extends EasySEOBaseWrapperState<EasySEONavWrapper> {}
