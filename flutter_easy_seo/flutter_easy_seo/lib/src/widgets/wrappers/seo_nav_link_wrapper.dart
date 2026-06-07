part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEONavLinkWrapper extends BaseSEOWrapper {
  final String path;
  final String? text;

  const SEONavLinkWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.additionalTags,
    required this.path,
    this.text,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return SEOHtml.li(children: [
      SEOHtml.a(
        href: path,
        content: text,
        children: children,
      ),
    ]);
  }

  @override
  State<StatefulWidget> createState() => _SEONavLinkWrapperState();
}

class _SEONavLinkWrapperState extends BaseSEOWrapperState<SEONavLinkWrapper> {}
