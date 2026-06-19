part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

extension EasySEOStringExtension on String {
  SEOHtml get easySeoH1 => SEOH1(this);
  SEOHtml get easySeoH2 => SEOH2(this);
  SEOHtml get easySeoH3 => SEOH3(this);
  SEOHtml get easySeoH4 => SEOH4(this);
  SEOHtml get easySeoH5 => SEOH5(this);
  SEOHtml get easySeoH6 => SEOH6(this);
  SEOHtml get easySeoP => SEOParagraph(this);
  SEOHtml get easySeoBrand => SEOParagraph(
        "",
        attributes: {'itemprop': 'brand'},
        jsonLd: {
          '@type': 'Brand',
          'name': this,
        },
      );
}
