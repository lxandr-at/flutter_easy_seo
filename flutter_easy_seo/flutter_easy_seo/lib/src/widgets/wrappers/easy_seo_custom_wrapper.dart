part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOCustomWrapper extends EasySEOBaseWrapper {
  final Widget Function(BuildContext, Widget)? builder;
  final String? tag;

  const EasySEOCustomWrapper({
    super.key,
    required super.child,
    this.builder,
    this.tag,
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
    return SEOHtml(tag: tag ?? 'div', children: children);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOCustomWrapperState();
}

class _EasySEOCustomWrapperState extends EasySEOBaseWrapperState<EasySEOCustomWrapper> {}
