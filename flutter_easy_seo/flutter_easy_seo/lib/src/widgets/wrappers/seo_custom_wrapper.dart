part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOCustomWrapper extends StatelessWidget implements SEOWrapper {
  final Widget child;
  final Widget Function(BuildContext, Widget)? builder;
  final String? tag;
  final String? className;
  final Map<String, String>? attributes;

  const SEOCustomWrapper({
    Key? key,
    required this.child,
    this.builder,
    this.tag,
    this.className,
    this.attributes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  String getOpenTag() {
    final buffer = StringBuffer('<${tag ?? 'div'}');
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
  String getCloseTag() => '</${tag ?? 'div'}>';
}