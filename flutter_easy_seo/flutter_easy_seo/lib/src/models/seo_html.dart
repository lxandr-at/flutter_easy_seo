part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Represents an HTML element that can be injected into the SEO output
/// without affecting the visual Flutter rendering.
///
/// Use [additionalTags] on any SEO wrapper to attach extra semantic HTML
/// alongside the widget's generated tag (e.g. structured-data spans, hidden
/// headings that live in a different part of the widget tree, etc.).
///
/// Example:
/// ```dart
/// SEOSectionWrapper(
///   additionalTags: [
///     SEOHtml(tag: 'h2', content: 'Section Subtitle'),
///     SEOHtml(
///       tag: 'script',
///       attributes: {'type': 'application/ld+json'},
///       content: '{"@type":"Article"}',
///     ),
///   ],
///   child: myWidget,
/// )
/// ```
class SEOHtml {
  final String tag;
  final String? content;
  final Map<String, String>? attributes;
  final List<SEOHtml> children;

  const SEOHtml({
    required this.tag,
    this.content,
    this.attributes,
    this.children = const [],
  });

  // Text-centric tags (content is a required positional argument, though it accepts null)
  const SEOHtml.h1(this.content, {this.attributes, this.children = const []}) : tag = 'h1';
  const SEOHtml.h2(this.content, {this.attributes, this.children = const []}) : tag = 'h2';
  const SEOHtml.h3(this.content, {this.attributes, this.children = const []}) : tag = 'h3';
  const SEOHtml.h4(this.content, {this.attributes, this.children = const []}) : tag = 'h4';
  const SEOHtml.h5(this.content, {this.attributes, this.children = const []}) : tag = 'h5';
  const SEOHtml.h6(this.content, {this.attributes, this.children = const []}) : tag = 'h6';
  const SEOHtml.p(this.content, {this.attributes, this.children = const []}) : tag = 'p';

  // Structural and semantic tags (content is named since they often just wrap children)
  const SEOHtml.div({this.content, this.attributes, this.children = const []}) : tag = 'div';
  const SEOHtml.span(this.content, {this.attributes, this.children = const []}) : tag = 'span';
  const SEOHtml.section({this.content, this.attributes, this.children = const []}) : tag = 'section';
  const SEOHtml.article({this.content, this.attributes, this.children = const []}) : tag = 'article';
  const SEOHtml.aside({this.content, this.attributes, this.children = const []}) : tag = 'aside';
  factory SEOHtml.header({
    String? h1,
    String? p,
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    final list = <SEOHtml>[...children];
    if (p != null) list.insert(0, SEOHtml.p(p));
    if (h1 != null) list.insert(0, SEOHtml.h1(h1));
    return SEOHtml(tag: 'header', content: content, attributes: attributes, children: list);
  }
  const SEOHtml.main({this.content, this.attributes, this.children = const []}) : tag = 'main';
  const SEOHtml.footer({this.content, this.attributes, this.children = const []}) : tag = 'footer';
  const SEOHtml.nav({this.content, this.attributes, this.children = const []}) : tag = 'nav';
  const SEOHtml.figure({this.content, this.attributes, this.children = const []}) : tag = 'figure';
  const SEOHtml.time({this.content, this.attributes, this.children = const []}) : tag = 'time';

  // List tags
  const SEOHtml.ul({this.content, this.attributes, this.children = const []}) : tag = 'ul';
  const SEOHtml.ol({this.content, this.attributes, this.children = const []}) : tag = 'ol';
  const SEOHtml.li({this.content, this.attributes, this.children = const []}) : tag = 'li';

  // Link and media tags
  SEOHtml.a({
    required String href,
    this.content,
    this.children = const [],
    Map<String, String> attributes = const {},
  })  : tag = 'a',
        attributes = {
          ...attributes,
          'href': href,
        };
  const SEOHtml.img({this.attributes})
      : tag = 'img',
        content = null,
        children = const [];

  // Metadata tags
  const SEOHtml.script({this.content, this.attributes})
      : tag = 'script',
        children = const [];
  const SEOHtml.meta({this.attributes})
      : tag = 'meta',
        content = null,
        children = const [];
  const SEOHtml.link({this.attributes})
      : tag = 'link',
        content = null,
        children = const [];

  // special tags for products
  SEOHtml.sizeUnit(String size, String unit)
      : tag = 'p',
        content = '',
        attributes = {
          'itemprop': 'additionalProperty', // change to height/width as needed
          'itemscope': '',
          'itemtype': 'https://schema.org/PropertyValue',
        },
        children = [
          SEOHtml.span(size, attributes: {'itemprop': 'value'}),
          SEOHtml.span(unit, attributes: {'itemprop': 'unitText'}),
        ];

  // HTML void elements — they have no closing tag.
  static const _voidElements = {
    'area',
    'base',
    'br',
    'col',
    'embed',
    'hr',
    'img',
    'input',
    'link',
    'meta',
    'param',
    'source',
    'track',
    'wbr',
  };

  bool get _isVoid => _voidElements.contains(tag);

  /// Recursively renders this element and all its [children] to an HTML string.
  String toHtmlString() {
    final buffer = StringBuffer('<$tag');

    if (attributes != null) {
      for (final entry in attributes!.entries) {
        buffer.write(' ${entry.key}="${_escapeAttr(entry.value)}"');
      }
    }

    if (_isVoid) {
      buffer.write(' />');
      return buffer.toString();
    }

    buffer.write('>');

    if (content != null) buffer.write(content);

    for (final child in children) {
      buffer.write(child.toHtmlString());
    }

    buffer.write('</$tag>');
    return buffer.toString();
  }

  String _escapeAttr(String value) => value.replaceAll('"', '&quot;').replaceAll("'", '&#39;');
}

/// Represents an item in a navigation menu for JSON-LD generation
class SEONavItem {
  final String text;
  final String url;

  const SEONavItem({required this.text, required this.url});
}

extension SEOHtmlJsonLd on SEOHtml {
  /// Generates a SiteNavigationElement JSON-LD script tag.
  static SEOHtml siteNavigation(List<SEONavItem> items) {
    final data = {
      "@context": "https://schema.org",
      "@type": "ItemList",
      "itemListElement": items
          .asMap()
          .entries
          .map((e) => {
                "@type": "SiteNavigationElement",
                "position": e.key + 1,
                "name": e.value.text,
                "url": e.value.url,
              })
          .toList(),
    };

    return SEOHtml.script(
      attributes: {'type': 'application/ld+json'},
      content: jsonEncode(data),
    );
  }

  /// Generates a BreadcrumbList JSON-LD script tag.
  static SEOHtml breadcrumbList(List<SEONavItem> items) {
    final data = {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items
          .asMap()
          .entries
          .map((e) => {
                "@type": "ListItem",
                "position": e.key + 1,
                "name": e.value.text,
                if (e.value.url.isNotEmpty) "item": e.value.url,
              })
          .toList(),
    };

    return SEOHtml.script(
      attributes: {'type': 'application/ld+json'},
      content: jsonEncode(data),
    );
  }

  /// Generates a Service JSON-LD script content.
  static String service(SEOServiceInfo info) {
    final data = {
      "@context": "https://schema.org",
      "@type": "Service",
      "mainEntityOfPage": {"@type": "WebPage"},
      "serviceType": info.serviceType,
      "provider": {
        "@type": "Organization",
        "name": info.providerName,
        "logo": info.brandLogoUrl,
        if (info.providerUrl != null) "url": info.providerUrl,
      },
      "areaServed": info.areasServed.map((area) => {"@type": "Country", "name": area}).toList(),
    };

    return jsonEncode(data);
  }
}
