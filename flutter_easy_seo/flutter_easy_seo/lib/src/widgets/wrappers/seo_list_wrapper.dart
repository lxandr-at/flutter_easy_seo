part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOListWrapper extends StatelessWidget implements SEOWrapper {
  final Widget child;
  final String tag;
  final String? className;
  final Map<String, String>? attributes;

  const SEOListWrapper({
    Key? key,
    required this.child,
    required this.tag,
    this.className,
    this.attributes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  String getOpenTag() {
    final buffer = StringBuffer('<${tag}');
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
  String getCloseTag() => '</${tag}>';
}