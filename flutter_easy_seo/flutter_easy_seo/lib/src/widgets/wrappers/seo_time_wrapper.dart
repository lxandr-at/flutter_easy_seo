part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOTimeWrapper extends BaseSEOWrapper {
  const SEOTimeWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.additionalTags,
    required DateTime dateTime,
  }) : _dateTime = dateTime;

  final DateTime _dateTime;

  @override
  Map<String, String> get additionalAttributes => {
    'datetime': _dateTime.toIso8601String(),
  };

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return _buildSimpleTag(tag: 'time', children: children, context: context);
  }

  @override
  State<StatefulWidget> createState() => _SEOTimeWrapperState();
}

class _SEOTimeWrapperState extends BaseSEOWrapperState<SEOTimeWrapper> {}
