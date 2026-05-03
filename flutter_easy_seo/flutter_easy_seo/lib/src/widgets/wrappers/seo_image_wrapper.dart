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
  String get tagName => 'img';

  @override
  Map<String, String> get additionalAttributes {
    String? extractedSrc = src;
    if (extractedSrc == null) {
      if (child is Image) {
        final provider = (child as Image).image;
        if (provider is NetworkImage) {
          extractedSrc = provider.url;
        }
      }
    }
    return {
      if (extractedSrc != null) 'src': extractedSrc,
      if (alt != null) 'alt': alt!,
    };
  }

  @override
  State<StatefulWidget> createState() => _SEOImageWrapperState();
}

class _SEOImageWrapperState extends BaseSEOWrapperState<SEOImageWrapper> {}
