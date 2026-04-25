part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOArticleWrapper extends StatelessWidget implements SEOWrapper {
  final Widget child;
  final String? className;
  final Map<String, String>? attributes;

  const SEOArticleWrapper({
    Key? key,
    required this.child,
    this.className,
    this.attributes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  String onEnter() {
    final buffer = StringBuffer('<article');
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
  String onExit() => '</article>';
}