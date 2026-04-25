part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEONavLinkWrapper extends StatelessWidget implements SEOWrapper {
  final Widget child;
  final String path;
  final String? className;
  final Map<String, String>? attributes;

  const SEONavLinkWrapper({
    Key? key,
    required this.child,
    required this.path,
    this.className,
    this.attributes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  String getOpenTag() {
    final buffer = StringBuffer('<a href="$path"');
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
  String getCloseTag() => '</a>';
}