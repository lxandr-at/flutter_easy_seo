part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEONavWrapper extends StatelessWidget implements SEOWrapper {
  final Widget child;
  final String? label;
  final String? className;
  final Map<String, String>? attributes;

  const SEONavWrapper({
    Key? key,
    required this.child,
    this.label,
    this.className,
    this.attributes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  String getOpenTag() {
    final buffer = StringBuffer();
    
    buffer.write('<nav');
    if (label != null) buffer.write(' aria-label="$label"');

    if (className != null) buffer.write(' class="$className"');
    if (attributes != null) {
      for (final entry in attributes!.entries) {
        buffer.write(' ${entry.key}="${entry.value}"');
      }
    }
    buffer.write('><ul>');

    return buffer.toString();
  }

  @override
  String getCloseTag() {
    return '</nav>';
  }
}