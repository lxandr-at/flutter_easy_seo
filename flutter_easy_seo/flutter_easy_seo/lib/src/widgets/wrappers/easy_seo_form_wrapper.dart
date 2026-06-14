part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOFormWrapper extends EasySEOBaseWrapper {
  const EasySEOFormWrapper({
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
    return _buildSimpleTag(tag: 'form', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOFormWrapperState();
}

class _EasySEOFormWrapperState extends EasySEOBaseWrapperState<EasySEOFormWrapper> {}
