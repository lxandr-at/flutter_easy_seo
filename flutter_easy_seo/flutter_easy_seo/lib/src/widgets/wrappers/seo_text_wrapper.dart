part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

abstract class SEOWrapper {
  String onEnter();
  String onExit();
}

abstract class SEOSelfClosingWrapper {
  String onEnter();
}

class SEOTextWrapper extends StatelessWidget implements SEOWrapper {
  final Widget child;
  final String? tag;
  final String? className;
  final Map<String, String>? attributes;

  const SEOTextWrapper({
    Key? key,
    required this.child,
    this.tag,
    this.className,
    this.attributes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  String onEnter() {
    final tagName = tag ?? 'p';
    final buffer = StringBuffer('<${tagName}');
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
  String onExit() => '</${tag ?? 'p'}>';
}