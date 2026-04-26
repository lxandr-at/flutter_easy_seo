part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOTimeWrapper extends BaseSEOWrapper {
  const SEOTimeWrapper({
    super.key,
    required Widget child,
    String? className,
    Map<String, String>? attributes,
    required DateTime dateTime,
  }) : _dateTime = dateTime, super(child: child, className: className, attributes: attributes);

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
}