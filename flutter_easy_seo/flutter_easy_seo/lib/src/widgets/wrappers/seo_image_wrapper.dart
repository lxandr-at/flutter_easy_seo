part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOImageWrapper extends BaseSEOWrapper {
  final String? alt;
  final String? src;

  const SEOImageWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.additionalTags,
    this.alt,
    this.src,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    final attrs = <String, String>{};
    if (className != null) attrs['class'] = className!;
    if (attributes != null) {
      for (final e in attributes!.entries) {
        if (e.value != null && e.value!.isNotEmpty) {
          attrs[e.key] = e.value!;
        } else {
          attrs[e.key] = '';
        }
      }
    }

    String? extractedSrc = src;
    if (extractedSrc == null) {
      if (child is Image) {
        final provider = (child as Image).image;
        if (provider is NetworkImage) {
          extractedSrc = provider.url;
        }
      }
    }
    if (extractedSrc != null) attrs['src'] = extractedSrc;
    if (alt != null) attrs['alt'] = alt!;

    return SEOHtml.img(attributes: attrs.isNotEmpty ? attrs : null);
  }

  @override
  State<StatefulWidget> createState() => _SEOImageWrapperState();
}

class _SEOImageWrapperState extends BaseSEOWrapperState<SEOImageWrapper> {}
