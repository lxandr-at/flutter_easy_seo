part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Extension on [String] to produce SEO-aware HTML elements ([SEOHtml] nodes)
/// directly from plain text — headings, paragraphs, and brand markup.
extension EasySEOStringExtension on String {
  /// `<h1>` heading element containing this string.
  SEOHtml get easySeoH1 => SEOH1(this);
  /// `<h2>` heading element containing this string.
  SEOHtml get easySeoH2 => SEOH2(this);
  /// `<h3>` heading element containing this string.
  SEOHtml get easySeoH3 => SEOH3(this);
  /// `<h4>` heading element containing this string.
  SEOHtml get easySeoH4 => SEOH4(this);
  /// `<h5>` heading element containing this string.
  SEOHtml get easySeoH5 => SEOH5(this);
  /// `<h6>` heading element containing this string.
  SEOHtml get easySeoH6 => SEOH6(this);
  /// `<p>` paragraph element containing this string.
  SEOHtml get easySeoP => SEOParagraph(this);
  /// `<p>` with `itemprop="brand"` and a `@type: Brand` JSON-LD stanza.
  SEOHtml get easySeoBrand => SEOParagraph(
        "",
        attributes: {'itemprop': 'brand'},
        jsonLd: {
          '@type': 'Brand',
          'name': this,
        },
      );
}
