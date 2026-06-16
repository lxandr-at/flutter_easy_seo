part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

// ---------------------------------------------------------------------------
// Text-centric tags
// ---------------------------------------------------------------------------

class SEOH1 extends SEOHtml {
  const SEOH1(
    String content, {
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'h1', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOH2 extends SEOHtml {
  const SEOH2(
    String content, {
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'h2', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOH3 extends SEOHtml {
  const SEOH3(
    String content, {
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'h3', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOH4 extends SEOHtml {
  const SEOH4(
    String content, {
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'h4', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOH5 extends SEOHtml {
  const SEOH5(
    String content, {
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'h5', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOH6 extends SEOHtml {
  const SEOH6(
    String content, {
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'h6', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOParagraph extends SEOHtml {
  const SEOParagraph(
    String content, {
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'p', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

// ---------------------------------------------------------------------------
// Structural and semantic tags
// ---------------------------------------------------------------------------

class SEODiv extends SEOHtml {
  const SEODiv({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'div', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOSpan extends SEOHtml {
  const SEOSpan(
    String content, {
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'span', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOSection extends SEOHtml {
  const SEOSection({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'section', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOArticle extends SEOHtml {
  const SEOArticle({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'article', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOAside extends SEOHtml {
  const SEOAside({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'aside', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOHeader extends SEOHtml {
  SEOHeader({
    String? h1,
    String? p,
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(
          tag: 'header',
          content: content,
          attributes: attributes,
          jsonLd: jsonLd,
          children: _buildHeaderChildren(h1, p, children),
        );

  static List<SEOHtml> _buildHeaderChildren(String? h1, String? p, List<SEOHtml> input) {
    final list = <SEOHtml>[...input];
    if (p != null) list.insert(0, SEOParagraph(p));
    if (h1 != null) list.insert(0, SEOH1(h1));
    return list;
  }
}

class SEOMain extends SEOHtml {
  const SEOMain({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'main', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOFooter extends SEOHtml {
  const SEOFooter({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'footer', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEONav extends SEOHtml {
  const SEONav({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'nav', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOFigure extends SEOHtml {
  const SEOFigure({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'figure', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOFigcaption extends SEOHtml {
  const SEOFigcaption({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'figcaption', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOTime extends SEOHtml {
  SEOTime({
    String? text,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
    required DateTime dateTime,
  }) : super(
          tag: 'time',
          content: text,
          children: children,
          jsonLd: jsonLd,
          attributes: _buildTimeAttrs(attributes, dateTime),
        );

  static Map<String, String>? _buildTimeAttrs(Map<String, String>? attrs, DateTime dateTime) {
    final result = <String, String>{};
    if (attrs != null) result.addAll(attrs);
    result['datetime'] = dateTime.toIso8601String();
    return result;
  }
}

// ---------------------------------------------------------------------------
// List tags
// ---------------------------------------------------------------------------

class SEOUnorderedList extends SEOHtml {
  const SEOUnorderedList({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'ul', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOOrderedList extends SEOHtml {
  const SEOOrderedList({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'ol', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

class SEOListItem extends SEOHtml {
  const SEOListItem({
    String? content,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'li', content: content, attributes: attributes, children: children, jsonLd: jsonLd);
}

// ---------------------------------------------------------------------------
// Link and media tags
// ---------------------------------------------------------------------------

class SEOAnchor extends SEOHtml {
  SEOAnchor({
    String? href,
    String? path,
    String? relativePath,
    String? content,
    List<SEOHtml> children = const [],
    Map<String, String> attributes = const {},
    Map<String, dynamic>? jsonLd,
  }) : super(
          tag: 'a',
          content: content,
          children: children,
          relativePath: relativePath,
          jsonLd: jsonLd,
          attributes: _resolveHref(href, path, attributes),
        );

  static Map<String, String> _resolveHref(String? href, String? path, Map<String, String> baseAttrs) {
    String finalHref = href ?? '';
    if (href == null && path != null) {
      finalHref = path.startsWith('http')
          ? path
          : EasySEOManager.instance.formatFullUrl(path);
    }
    return {
      ...baseAttrs,
      if (finalHref.isNotEmpty) 'href': finalHref,
    };
  }
}

class SEOImage extends SEOHtml {
  const SEOImage({
    Map<String, String>? attributes,
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'img', attributes: attributes, jsonLd: jsonLd);
}

// ---------------------------------------------------------------------------
// Metadata tags
// ---------------------------------------------------------------------------

class SEOScript extends SEOHtml {
  const SEOScript({
    String? content,
    Map<String, String>? attributes,
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'script', content: content, attributes: attributes, jsonLd: jsonLd);
}

class SEOMeta extends SEOHtml {
  const SEOMeta({
    Map<String, String>? attributes,
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'meta', attributes: attributes, jsonLd: jsonLd);
}

class SEOLink extends SEOHtml {
  const SEOLink({
    Map<String, String>? attributes,
    Map<String, dynamic>? jsonLd,
  }) : super(tag: 'link', attributes: attributes, jsonLd: jsonLd);
}

class SEOSizeUnit extends SEOHtml {
  SEOSizeUnit(
    String size,
    String unit,
  ) : super(
          tag: 'p',
          content: '',
          attributes: {'itemprop': 'additionalProperty'},
          jsonLd: {
            '@type': 'PropertyValue',
            'name': 'weight',
            'value': size,
            'unitText': unit,
          },
        );
}

class SEOBrand extends SEOHtml {
  SEOBrand(String name) : super(
    tag: 'p',
    content: '',
    attributes: {'itemprop': 'brand'},
    jsonLd: {
      '@type': 'Brand',
      'name': name,
    },
  );
}

class SEOProductOffers extends SEOHtml {
  SEOProductOffers({
    required double lowPrice,
    required double highPrice,
    required int offerCount,
    String currency = 'EUR',
    List<Map<String, dynamic>> individualOffers = const [],
    DateTime? validThrough,
    DateTime? validFrom,
  }) : super(
    tag: 'div',
    attributes: {'itemprop': 'offers', 'class': 'aggregateOffer'},
    jsonLd: {
      '@type': 'AggregateOffer',
      'lowPrice': lowPrice,
      'highPrice': highPrice,
      'offerCount': offerCount,
      'priceCurrency': currency,
      'offers': individualOffers.map((offer) {
        return {
          '@type': 'Offer',
          'price': offer['price'],
          'priceCurrency': currency,
          'itemCondition': 'https://schema.org/NewCondition',
          'availability': (offer['availability'] ?? true)
              ? 'https://schema.org/InStock'
              : 'https://schema.org/OutOfStock',
          'seller': {
            '@type': 'Organization',
            'name': offer['seller'].toString(),
          },
          if (validThrough != null)
            'validThrough': validThrough!.toIso8601String(),
          if (validFrom != null)
            'validFrom': validFrom!.toIso8601String(),
        };
      }).toList(),
    },
  );
}
