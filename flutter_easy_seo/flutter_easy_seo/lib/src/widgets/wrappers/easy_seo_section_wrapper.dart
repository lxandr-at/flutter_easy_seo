part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOSectionWrapper extends EasySEOBaseWrapper {
  const EasySEOSectionWrapper({
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
    return _buildSimpleTag(tag: 'section', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOSectionWrapperState();
}

class _EasySEOSectionWrapperState extends EasySEOBaseWrapperState<EasySEOSectionWrapper> {}
