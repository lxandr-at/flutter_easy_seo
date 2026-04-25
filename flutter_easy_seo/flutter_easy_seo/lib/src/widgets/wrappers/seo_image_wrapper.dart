part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOImageWrapper extends StatelessWidget implements SEOSelfClosingWrapper {
  final Widget child;
  final String? alt;
  final String? caption;
  final String? className;
  final String? src;
  final Map<String, String>? attributes;

  const SEOImageWrapper({
    Key? key,
    required this.child,
    this.alt,
    this.caption,
    this.className,
    this.src,
    this.attributes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  String onEnter({String? resolvedSrc}) {
    final imageSrc = resolvedSrc ?? src;
    final buffer = StringBuffer('<img');
    if (imageSrc != null) buffer.write(' src="$imageSrc"');
    if (alt != null) buffer.write(' alt="$alt"');
    if (className != null) buffer.write(' class="$className"');
    if (attributes != null) {
      for (final entry in attributes!.entries) {
        buffer.write(' ${entry.key}="${entry.value}"');
      }
    }
    buffer.write(' />');
    return buffer.toString();
  }
}