part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Extension for custom widget mapping
extension SEOWidgetExtension on Widget {
  Widget seo({
    Widget Function(BuildContext, Widget)? builder,
    String? tag,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOCustomWrapper(
      builder: builder,
      tag: tag,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoText({
    SEOTextType textType = SEOTextType.p,
    String? className,
    Map<String, String>? attributes,
    String? text,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOTextWrapper(
      textType: textType,
      className: className,
      attributes: attributes,
      text: text,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoH1({String? text}) => seoText(textType: SEOTextType.h1, text: text);
  Widget seoH2({String? text}) => seoText(textType: SEOTextType.h2, text: text);
  Widget seoH3({String? text}) => seoText(textType: SEOTextType.h3, text: text);
  Widget seoH4({String? text}) => seoText(textType: SEOTextType.h4, text: text);
  Widget seoH5({String? text}) => seoText(textType: SEOTextType.h5, text: text);
  Widget seoH6({String? text}) => seoText(textType: SEOTextType.h6, text: text);
  Widget seoP({String? text}) => seoText(textType: SEOTextType.p, text: text);

  Widget seoNavLink({
    required String path,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEONavLinkWrapper(
      path: path,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoSection({String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOSectionWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoArticle({String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOArticleWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoList({String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOListWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoListItem({String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOListItemWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoHtml({
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOCustomWrapper(
      tag: "",
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoProduct(String productName) {
    return SEOArticleWrapper(
    attributes: const {'itemscope': null, 'itemtype': "https://schema.org/Product"},
    additionalTags: [SEOHtml.h3(productName, attributes: {'itemprop': "name"})],
    child: this,
    );
  }

  Widget seoBrand(String brandName) {
    return SEOTextWrapper(
      attributes: const {'itemprop': "brand", 'itemscope': null, 'itemtype': "https://schema.org/Brand"},
      additionalTags: [SEOHtml.span(brandName, attributes: {'itemprop': "name"})],
      child: this,
    );
  }
}
