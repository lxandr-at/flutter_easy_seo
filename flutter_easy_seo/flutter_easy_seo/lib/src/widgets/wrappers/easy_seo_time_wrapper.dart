part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOTimeWrapper extends EasySEOBaseWrapper {
  const EasySEOTimeWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.additionalTags,
    required DateTime dateTime,
    this.text,
  }) : _dateTime = dateTime;

  final DateTime _dateTime;
  final String? text;

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
    return _buildSimpleTag(tag: 'time', children: children, context: context, content: text);
  }

  @override
  State<StatefulWidget> createState() => _EasySEOTimeWrapperState();
}

class _EasySEOTimeWrapperState extends EasySEOBaseWrapperState<EasySEOTimeWrapper> {}
