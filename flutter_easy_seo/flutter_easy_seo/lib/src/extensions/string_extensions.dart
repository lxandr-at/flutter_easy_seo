part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

extension EasySEOStringExtension on String {
  SEOHtml get easySeoH1 => SEOHtml.h1(this);
  SEOHtml get easySeoH2 => SEOHtml.h2(this);
  SEOHtml get easySeoH3 => SEOHtml.h3(this);
  SEOHtml get easySeoH4 => SEOHtml.h4(this);
  SEOHtml get easySeoH5 => SEOHtml.h5(this);
  SEOHtml get easySeoH6 => SEOHtml.h6(this);
  SEOHtml get easySeoP => SEOHtml.p(this);
  SEOHtml get easySeoBrand => SEOHtml.p(
        "",
        attributes: {'itemprop': 'brand'},
        jsonLd: {
          '@type': 'Brand',
          'name': this,
        },
      );
}
