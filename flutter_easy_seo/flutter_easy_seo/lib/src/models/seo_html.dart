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
  final String? relativePath;

  const SEOHtml({
    required this.tag,
    this.content,
    this.attributes,
    this.children = const [],
    this.relativePath,
  });

  // Text-centric tags (content is a required positional argument, though it accepts null)
  const SEOHtml.h1(this.content, {this.attributes, this.children = const []}) : tag = 'h1', relativePath = null;
  const SEOHtml.h2(this.content, {this.attributes, this.children = const []}) : tag = 'h2', relativePath = null;
  const SEOHtml.h3(this.content, {this.attributes, this.children = const []}) : tag = 'h3', relativePath = null;
  const SEOHtml.h4(this.content, {this.attributes, this.children = const []}) : tag = 'h4', relativePath = null;
  const SEOHtml.h5(this.content, {this.attributes, this.children = const []}) : tag = 'h5', relativePath = null;
  const SEOHtml.h6(this.content, {this.attributes, this.children = const []}) : tag = 'h6', relativePath = null;
  const SEOHtml.p(this.content, {this.attributes, this.children = const []}) : tag = 'p', relativePath = null;

  // Structural and semantic tags (content is named since they often just wrap children)
  const SEOHtml.div({this.content, this.attributes, this.children = const []}) : tag = 'div', relativePath = null;
  const SEOHtml.span(this.content, {this.attributes, this.children = const []}) : tag = 'span', relativePath = null;
  const SEOHtml.section({this.content, this.attributes, this.children = const []}) : tag = 'section', relativePath = null;
  const SEOHtml.article({this.content, this.attributes, this.children = const []}) : tag = 'article', relativePath = null;
  const SEOHtml.aside({this.content, this.attributes, this.children = const []}) : tag = 'aside', relativePath = null;
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
  const SEOHtml.main({this.content, this.attributes, this.children = const []}) : tag = 'main', relativePath = null;
  const SEOHtml.footer({this.content, this.attributes, this.children = const []}) : tag = 'footer', relativePath = null;
  const SEOHtml.nav({this.content, this.attributes, this.children = const []}) : tag = 'nav', relativePath = null;
  const SEOHtml.figure({this.content, this.attributes, this.children = const []}) : tag = 'figure', relativePath = null;
  const SEOHtml.time({this.content, this.attributes, this.children = const []}) : tag = 'time', relativePath = null;

  // List tags
  const SEOHtml.ul({this.content, this.attributes, this.children = const []}) : tag = 'ul', relativePath = null;
  const SEOHtml.ol({this.content, this.attributes, this.children = const []}) : tag = 'ol', relativePath = null;
  const SEOHtml.li({this.content, this.attributes, this.children = const []}) : tag = 'li', relativePath = null;

  // Link and media tags
  factory SEOHtml.a({
    String? href,
    String? path,
    String? relativePath,
    String? content,
    List<SEOHtml> children = const [],
    Map<String, String> attributes = const {},
  }) {
    String finalHref = href ?? '';
    if (href == null && path != null) {
      finalHref = EasySEOManager.instance.formatFullUrl(path);
    }

    return SEOHtml(
      tag: 'a',
      content: content,
      children: children,
      relativePath: relativePath,
      attributes: {
        ...attributes,
        if (finalHref.isNotEmpty) 'href': finalHref,
      },
    );
  }
  const SEOHtml.img({this.attributes})
      : tag = 'img',
        content = null,
        children = const [],
        relativePath = null;

  // Metadata tags
  const SEOHtml.script({this.content, this.attributes})
      : tag = 'script',
        children = const [],
        relativePath = null;
  const SEOHtml.meta({this.attributes})
      : tag = 'meta',
        content = null,
        children = const [],
        relativePath = null;
  const SEOHtml.link({this.attributes})
      : tag = 'link',
        content = null,
        children = const [],
        relativePath = null;

  SEOHtml.sizeUnit(String size, String unit)
      : tag = 'p',
        content = '',
        attributes = {
          'itemprop': 'additionalProperty', // change to height/width as needed
          'itemscope': '',
          'itemtype': 'https://schema.org/PropertyValue',
        },
        children = [
          SEOHtml.meta(attributes: {'itemprop': 'name', 'content': 'weight'}),
          SEOHtml.span(size, attributes: {'itemprop': 'value', 'content': size}),
          SEOHtml.span(unit, attributes: {'itemprop': 'unitText', 'content': unit}),
        ],
        relativePath = null;

  // Helper for AggregateOffer
  /// assumes 'price' and 'seller' in individualOffers
  static SEOHtml aggregateOffer(SEOOfferInfo info) {
    return SEOHtml.div(
      attributes: {
        'itemprop': 'offers',
        'itemscope': '',
        'itemtype': 'https://schema.org/AggregateOffer',
      },
      children: [
        SEOHtml.meta(attributes: {'itemprop': 'lowPrice', 'content': info.lowPrice.toString()}),
        SEOHtml.meta(attributes: {'itemprop': 'highPrice', 'content': info.highPrice.toString()}),
        SEOHtml.meta(attributes: {'itemprop': 'offerCount', 'content': info.offerCount.toString()}),
        SEOHtml.meta(attributes: {'itemprop': 'priceCurrency', 'content': info.currency}),
        ...info.individualOffers.map((offer) {
          return SEOHtml.div(
            attributes: {
              'itemscope': '',
              'itemtype': 'https://schema.org/Offer',
            },
            children: [
              SEOHtml.meta(attributes: {'itemprop': 'price', 'content': offer['price'].toString()}),
              SEOHtml.meta(attributes: {'itemprop': 'priceCurrency', 'content': info.currency}),
              SEOHtml.link(attributes: {'itemprop': 'itemCondition', 'href': "https://schema.org/NewCondition"}),
              SEOHtml.link(attributes: {
                'itemprop': 'availability',
                'href': (offer["availability"] ?? true) ? "https://schema.org/InStock" : "https://schema.org/OutOfStock"
              }),
              SEOHtml.div(
                attributes: {
                  'itemprop': 'seller',
                  'itemscope': '',
                  'itemtype': 'https://schema.org/Organization',
                },
                children: [
                  SEOHtml.meta(attributes: {'itemprop': 'name', 'content': offer['seller'].toString()}),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

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

  /// True when children contain at least one node that produces visible output
  /// (i.e. has a non-empty tag, content, or recursively has such children).
  /// Empty transparent containers are ignored so parents can keep inline formatting.
  bool get _hasRealChildren {
    for (final child in children) {
      if (child.tag.isNotEmpty || child.content != null || child._hasRealChildren) return true;
    }
    return false;
  }

  /// Recursively renders this element and all its [children] to an HTML string with formatting.
  String toHtmlString({int indentLevel = 0}) {
    final indent = '  ' * indentLevel;
    if (tag.isEmpty) {
      final buffer = StringBuffer();
      if (content != null) {
        buffer.write(indent);
        buffer.writeln(content);
      }
      for (final child in children) {
        buffer.write(child.toHtmlString(indentLevel: indentLevel));
      }
      return buffer.toString();
    }

    final buffer = StringBuffer();
    buffer.write(indent);
    buffer.write('<$tag');

    if (attributes != null) {
      for (final entry in attributes!.entries) {
        if (entry.value.isNotEmpty) {
          buffer.write(' ${entry.key}="${_escapeAttr(entry.value)}"');
        } else {
          buffer.write(' ${entry.key}');
        }
      }
    }

    if (_isVoid) {
      buffer.write(' />\n');
      return buffer.toString();
    }

    buffer.write('>');

    final hasSubElements = _hasRealChildren || (content != null && content!.contains('\n'));

    if (hasSubElements) {
      buffer.writeln();
      if (content != null && content!.isNotEmpty) {
        buffer.write('  ' * (indentLevel + 1));
        buffer.writeln(content);
      }
      for (final child in children) {
        buffer.write(child.toHtmlString(indentLevel: indentLevel + 1));
      }
      buffer.write(indent);
      buffer.write('</$tag>\n');
    } else {
      if (content != null) {
        buffer.write(content);
      }
      buffer.write('</$tag>\n');
    }

    return buffer.toString();
  }

  String _escapeAttr(String value) => value.replaceAll('"', '&quot;').replaceAll("'", '&#39;');

  /// Dynamically resolves relative path to an absolute URL during traversal.
  SEOHtml resolve(BuildContext context) {
    String? resolvedHref;
    Map<String, String>? resolvedAttributes = attributes != null ? Map.from(attributes!) : null;

    if (relativePath != null) {
      final currentPath = EasySEOManager.instance.getCurrentPath(context);
      final urls = EasySEOManager.instance.resolveSeoUrls(currentPath);
      final baseUrl = urls.canonicalUrl;
      final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final cleanPath = relativePath!.startsWith('/') ? relativePath! : '/$relativePath';
      resolvedHref = '$cleanBase$cleanPath';

      resolvedAttributes ??= {};
      resolvedAttributes['href'] = resolvedHref;
    }

    final resolvedChildren = children.map((c) => c.resolve(context)).toList();

    return SEOHtml(
      tag: tag,
      content: content,
      attributes: resolvedAttributes,
      children: resolvedChildren,
      relativePath: relativePath,
    );
  }
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
