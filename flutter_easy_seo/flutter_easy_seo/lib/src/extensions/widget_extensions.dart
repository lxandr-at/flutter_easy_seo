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

  Widget seoH1({String? text, List<SEOHtml> additionalTags = const []}) =>
      seoText(textType: SEOTextType.h1, text: text, additionalTags: additionalTags);
  Widget seoH2({String? text, List<SEOHtml> additionalTags = const []}) =>
      seoText(textType: SEOTextType.h2, text: text, additionalTags: additionalTags);
  Widget seoH3({String? text, List<SEOHtml> additionalTags = const []}) =>
      seoText(textType: SEOTextType.h3, text: text, additionalTags: additionalTags);
  Widget seoH4({String? text, List<SEOHtml> additionalTags = const []}) =>
      seoText(textType: SEOTextType.h4, text: text, additionalTags: additionalTags);
  Widget seoH5({String? text, List<SEOHtml> additionalTags = const []}) =>
      seoText(textType: SEOTextType.h5, text: text, additionalTags: additionalTags);
  Widget seoH6({String? text, List<SEOHtml> additionalTags = const []}) =>
      seoText(textType: SEOTextType.h6, text: text, additionalTags: additionalTags);
  Widget seoP({String? text, List<SEOHtml> additionalTags = const []}) =>
      seoText(textType: SEOTextType.p, text: text, additionalTags: additionalTags);

  Widget seoNavLink({
    required String path,
    required String text,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEONavLinkWrapper(
      path: path,
      text: text,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoHeader({
    String? h1,
    String? p,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOHeaderWrapper(
      h1: h1,
      p: p,
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

  Widget seoMain({String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOMainWrapper(
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

  Widget seoProduct(
    String productName,
    {
      String? path,
      SEOHtml Function(String? content, {Map<String, String>? attributes,List<SEOHtml> children,}) headingBuilder = SEOHtml.h1,
      List<SEOHtml> additionalTags = const []
    }
  ) {
    return SEOArticleWrapper(
      attributes: const {'itemscope': null, 'itemtype': "https://schema.org/Product"},
      jsonLd: {
        '@type': 'Product',
        'name': productName,
        // url is extracted from the child <a itemprop="url"> by _extractMicrodataValue()
      },
      additionalTags: [
        headingBuilder(
            path == null ? productName : '',
            attributes: {'itemprop': "name"},
            children: [
              if (path != null)
                SEOHtml.a(content: productName, relativePath: path, attributes: {'itemprop': "url"})
            ]),
        ...additionalTags
      ],
      child: this,
    );
  }

  Widget seoBrand(String brandName) {
    return SEOTextWrapper(
      attributes: const {'itemprop': "brand"},
      jsonLd: {
        '@type': 'Brand',
        'name': brandName,
      },
      child: this,
    );
  }

  Widget seoImage({String? name, String? url}) {
    return SEOImageWrapper(alt: name, src: url, attributes: {'itemprop': "image"}, child: this);
  }

  Widget seoAside({String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOAsideWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoContainer({String tag = 'div', String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOContainerWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoFigure({String? caption, String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOFigureWrapper(
      caption: caption,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoForm({String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOFormWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoNav({String? label, bool isBreadcrumb = false, String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEONavWrapper(
      label: label,
      isBreadcrumb: isBreadcrumb,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget seoTime({required DateTime dateTime, String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEOTimeWrapper(
      dateTime: dateTime,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}
