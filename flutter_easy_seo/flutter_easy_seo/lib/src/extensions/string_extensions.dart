part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

extension SEOStringExtension on String {
  SEOHtml get seoH1 => SEOHtml.h1(this);
  SEOHtml get seoH2 => SEOHtml.h2(this);
  SEOHtml get seoH3 => SEOHtml.h3(this);
  SEOHtml get seoH4 => SEOHtml.h4(this);
  SEOHtml get seoH5 => SEOHtml.h5(this);
  SEOHtml get seoH6 => SEOHtml.h6(this);
  SEOHtml get seoP => SEOHtml.p(this);
  SEOHtml get seoBrand => SEOHtml.p(
        "",
        attributes: {
          'itemprop': 'brand',
          'itemscope': '',
          'itemtype': 'https://schema.org/Brand',
        },
        children: [
          SEOHtml.span(
            this,
            attributes: {'itemprop': "name"},
          ),
        ],
      );
}
