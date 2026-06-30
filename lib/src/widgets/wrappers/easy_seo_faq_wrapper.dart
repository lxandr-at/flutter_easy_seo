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
      return SEOHtml(tag: 'section', children: children);
    }

    final allChildren = <SEOHtml>[
      for (final item in items) _buildFaqItem(item),
      ...children,
    ];

    return SEOSection(
      attributes: {'itemscope': '', 'itemtype': 'https://schema.org/FAQPage'},
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
