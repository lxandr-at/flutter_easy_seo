part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Model for SEO tags
class SEOTag {
  final String tagName;
  final Map<String, String> attributes;

  const SEOTag(this.tagName, this.attributes);
}

/// Model for Meta tags
class MetaTag extends SEOTag {
  final String name;
  final String content;

  MetaTag({required this.name, required this.content}) : super('meta', {'name': name, 'content': content});
}

/// Model for Link tags
class LinkTag extends SEOTag {
  final String rel;
  final String href;
  final String? hreflang;

  LinkTag({required this.rel, required this.href, this.hreflang}) 
    : super('link', {
        'rel': rel,
        'href': href,
        if (hreflang != null) 'hreflang': hreflang,
      });
}
