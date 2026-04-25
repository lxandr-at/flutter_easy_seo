part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOTimeWrapper extends StatelessWidget implements SEOWrapper {
  final Widget child;
  final String? className;
  final Map<String, String>? attributes;
  final DateTime dateTime;

  const SEOTimeWrapper({
    Key? key,
    required this.child,
    this.className,
    this.attributes,
    required this.dateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  String getOpenTag() {
    final buffer = StringBuffer('<time datetime="${dateTime.toIso8601String()}"');
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
  String getCloseTag() => '</time>';
}