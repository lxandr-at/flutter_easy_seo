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
    super.additionalTags,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return _buildSimpleTag(tag: tag ?? 'div', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOCustomWrapperState();
}

class _EasySEOCustomWrapperState extends EasySEOBaseWrapperState<EasySEOCustomWrapper> {}
