part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOContainerWrapper extends EasySEOBaseWrapper {
  const EasySEOContainerWrapper({
    super.key,
    required super.child,
    String tag = 'div',
    super.className,
    super.attributes,
    super.globalName,
    super.children,
  }) : _tag = tag;

  final String _tag;

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return _buildSimpleTag(tag: _tag, children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOContainerWrapperState();
}

class _EasySEOContainerWrapperState extends EasySEOBaseWrapperState<EasySEOContainerWrapper> {}
