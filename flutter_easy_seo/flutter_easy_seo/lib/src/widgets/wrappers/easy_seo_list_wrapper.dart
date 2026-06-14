part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOListWrapper extends EasySEOBaseWrapper {
  const EasySEOListWrapper({
    super.key,
    required super.child,
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
    return _buildSimpleTag(tag: 'ul', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOListWrapperState();
}

class _EasySEOListWrapperState extends EasySEOBaseWrapperState<EasySEOListWrapper> {}
