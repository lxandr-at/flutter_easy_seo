part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOListItemWrapper extends EasySEOBaseWrapper {
  const EasySEOListItemWrapper({
    super.key,
    required super.child,
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
    return _buildSimpleTag(tag: 'li', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOListItemWrapperState();
}

class _EasySEOListItemWrapperState extends EasySEOBaseWrapperState<EasySEOListItemWrapper> {}
