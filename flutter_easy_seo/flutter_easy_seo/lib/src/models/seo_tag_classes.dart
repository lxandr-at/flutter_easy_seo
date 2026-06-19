part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

// ---------------------------------------------------------------------------
// Text-centric tags
// ---------------------------------------------------------------------------

class SEOH1 extends SEOHtml {
  const SEOH1(
    String content, {
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'h1', content: content);
}

class SEOH2 extends SEOHtml {
  const SEOH2(
    String content, {
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'h2', content: content);
}

class SEOH3 extends SEOHtml {
  const SEOH3(
    String content, {
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'h3', content: content);
}

class SEOH4 extends SEOHtml {
  const SEOH4(
    String content, {
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'h4', content: content);
}

class SEOH5 extends SEOHtml {
  const SEOH5(
    String content, {
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'h5', content: content);
}

class SEOH6 extends SEOHtml {
  const SEOH6(
    String content, {
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'h6', content: content);
}

class SEOParagraph extends SEOHtml {
  const SEOParagraph(
    String content, {
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'p', content: content);
}

// ---------------------------------------------------------------------------
// Structural and semantic tags
// ---------------------------------------------------------------------------

class SEODiv extends SEOHtml {
  const SEODiv({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'div');
}

class SEOSpan extends SEOHtml {
  const SEOSpan(
    String content, {
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'span', content: content);
}

class SEOSection extends SEOHtml {
  const SEOSection({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'section');
}

class SEOArticle extends SEOHtml {
  const SEOArticle({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'article');
}

class SEOAside extends SEOHtml {
  const SEOAside({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'aside');
}

class SEOHeader extends SEOHtml {
  SEOHeader({
    String? h1,
    String? p,
    super.content,
    super.attributes,
    super.jsonLd,
    List<SEOHtml> children = const [],
  }) : super(
          tag: 'header',
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
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'main');
}

class SEOFooter extends SEOHtml {
  const SEOFooter({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'footer');
}

class SEONav extends SEOHtml {
  const SEONav({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'nav');
}

class SEOFigure extends SEOHtml {
  const SEOFigure({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'figure');
}

class SEOFigcaption extends SEOHtml {
  const SEOFigcaption({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'figcaption');
}

class SEOTime extends SEOHtml {
  SEOTime({
    String? text,
    Map<String, String>? attributes,
    super.children,
    super.jsonLd,
    required DateTime dateTime,
  }) : super(
          tag: 'time',
          content: text,
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
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'ul');
}

class SEOOrderedList extends SEOHtml {
  const SEOOrderedList({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'ol');
}

class SEOListItem extends SEOHtml {
  const SEOListItem({
    super.content,
    super.attributes,
    super.children,
    super.jsonLd,
  }) : super(tag: 'li');
}

// ---------------------------------------------------------------------------
// Link and media tags
// ---------------------------------------------------------------------------

class SEOAnchor extends SEOHtml {
  SEOAnchor({
    String? href,
    String? path,
    super.relativePath,
    super.content,
    super.children,
    super.jsonLd,
    Map<String, String> attributes = const {},
  }) : super(
          tag: 'a',
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
    super.attributes,
    super.jsonLd,
  }) : super(tag: 'img');
}

// ---------------------------------------------------------------------------
// Metadata tags
// ---------------------------------------------------------------------------

class SEOScript extends SEOHtml {
  const SEOScript({
    super.content,
    super.attributes,
    super.jsonLd,
  }) : super(tag: 'script');
}

class SEOMeta extends SEOHtml {
  const SEOMeta({
    super.attributes,
    super.jsonLd,
  }) : super(tag: 'meta');
}

class SEOLink extends SEOHtml {
  const SEOLink({
    super.attributes,
    super.jsonLd,
  }) : super(tag: 'link');
}

class SEOSizeUnit extends SEOHtml {
  SEOSizeUnit(
    String size,
    String unit,
  ) : super(
          tag: 'p',
          content: '$size $unit',
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
    content: name,
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
            'validThrough': validThrough.toIso8601String(),
          if (validFrom != null)
            'validFrom': validFrom.toIso8601String(),
        };
      }).toList(),
    },
  );
}
