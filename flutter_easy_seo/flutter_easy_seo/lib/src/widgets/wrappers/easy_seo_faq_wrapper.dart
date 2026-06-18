part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOFaqWrapper extends EasySEOBaseWrapper {
  final List<EasySEOFaqItem> items;

  const EasySEOFaqWrapper({
    super.key,
    required super.child,
    required this.items,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
  });

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    if (items.isEmpty) {
      return _buildSimpleTag(tag: 'section', children: children, context: context);
    }

    final mergedAttrs = _buildAttributes() ?? <String, String>{};
    mergedAttrs['itemscope'] = '';
    mergedAttrs['itemtype'] = 'https://schema.org/FAQPage';

    final allChildren = <SEOHtml>[
      for (final item in items) _buildFaqItem(item),
      ...this.children,
      ...children,
    ];

    return SEOSection(
      attributes: mergedAttrs,
      jsonLd: {'@type': 'FAQPage'},
      children: allChildren,
    );
  }

  SEOHtml _buildFaqItem(EasySEOFaqItem item) {
    return SEODiv(
      attributes: {
        'itemprop': 'mainEntity',
        'itemscope': '',
        'itemtype': 'https://schema.org/Question',
      },
      jsonLd: {
        '@type': 'Question',
        'name': item.question,
        'acceptedAnswer': {
          '@type': 'Answer',
          'text': item.answer,
        },
      },
      children: [
        SEOH3(item.question, attributes: {'itemprop': 'name'}),
        SEODiv(
          attributes: {
            'itemprop': 'acceptedAnswer',
            'itemscope': '',
            'itemtype': 'https://schema.org/Answer',
          },
          jsonLd: {
            '@type': 'Answer',
            'text': item.answer,
          },
          children: [
            SEOParagraph(item.answer, attributes: {'itemprop': 'text'}),
          ],
        ),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _EasySEOFaqWrapperState();
}

class _EasySEOFaqWrapperState extends EasySEOBaseWrapperState<EasySEOFaqWrapper> {}
