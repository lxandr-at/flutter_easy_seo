part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOTimeWrapper extends BaseSEOWrapper {
  const SEOTimeWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.additionalTags,
    required DateTime dateTime,
  }) : _dateTime = dateTime;

  final DateTime _dateTime;

  @override
  String get tagName => 'time';

  @override
  String getOpenTag({Map<String, String> overrideAttributes = const {}}) {
    final buffer = StringBuffer('<time datetime="${_dateTime.toIso8601String()}"');
    if (className != null) buffer.write(' class="$className"');
    if (attributes != null) {
      for (final entry in attributes!.entries) {
        buffer.write(' ${entry.key}="${entry.value}"');
      }
    }
    buffer.write('>');
    return buffer.toString();
  }

  @override
  State<StatefulWidget> createState() => _SEOTimeWrapperState();
}

class _SEOTimeWrapperState extends BaseSEOWrapperState<SEOTimeWrapper> {}
