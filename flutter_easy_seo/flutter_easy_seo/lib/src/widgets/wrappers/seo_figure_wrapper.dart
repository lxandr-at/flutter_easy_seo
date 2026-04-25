part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOFigureWrapper extends StatelessWidget implements SEOWrapper {
  final Widget child;
  final String? caption;
  final String? className;
  final Map<String, String>? attributes;

  const SEOFigureWrapper({
    Key? key,
    required this.child,
    this.caption,
    this.className,
    this.attributes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  String onEnter() {
    final buffer = StringBuffer('<figure');
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
  String onExit() => '</figure>';
}