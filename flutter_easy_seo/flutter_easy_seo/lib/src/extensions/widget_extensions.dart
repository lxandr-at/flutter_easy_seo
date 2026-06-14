part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Extension for custom widget mapping
extension EasySEOWidgetExtension on Widget {
  Widget easySeo({
    Widget Function(BuildContext, Widget)? builder,
    String? tag,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> additionalTags = const [],
  }) {
    return EasySEOCustomWrapper(
      builder: builder,
      tag: tag,
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoText({
    SEOTextType textType = SEOTextType.p,
    String? className,
    Map<String, String>? attributes,
    String? text,
    String? globalName,
    List<SEOHtml> additionalTags = const [],
  }) {
    return EasySEOTextWrapper(
      textType: textType,
      className: className,
      attributes: attributes,
      text: text,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoH1({String? text, String? globalName, List<SEOHtml> additionalTags = const []}) =>
      easySeoText(textType: SEOTextType.h1, text: text, globalName: globalName, additionalTags: additionalTags);
  Widget easySeoH2({String? text, String? globalName, List<SEOHtml> additionalTags = const []}) =>
      easySeoText(textType: SEOTextType.h2, text: text, globalName: globalName, additionalTags: additionalTags);
  Widget easySeoH3({String? text, String? globalName, List<SEOHtml> additionalTags = const []}) =>
      easySeoText(textType: SEOTextType.h3, text: text, globalName: globalName, additionalTags: additionalTags);
  Widget easySeoH4({String? text, String? globalName, List<SEOHtml> additionalTags = const []}) =>
      easySeoText(textType: SEOTextType.h4, text: text, globalName: globalName, additionalTags: additionalTags);
  Widget easySeoH5({String? text, String? globalName, List<SEOHtml> additionalTags = const []}) =>
      easySeoText(textType: SEOTextType.h5, text: text, globalName: globalName, additionalTags: additionalTags);
  Widget easySeoH6({String? text, String? globalName, List<SEOHtml> additionalTags = const []}) =>
      easySeoText(textType: SEOTextType.h6, text: text, globalName: globalName, additionalTags: additionalTags);
  Widget easySeoP({String? text, String? globalName, List<SEOHtml> additionalTags = const []}) =>
      easySeoText(textType: SEOTextType.p, text: text, globalName: globalName, additionalTags: additionalTags);

  Widget easySeoNavLink({
    required String path,
    required String text,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> additionalTags = const [],
  }) {
    return EasySEONavLinkWrapper(
      path: path,
      text: text,
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoHeader({
    String? h1,
    String? p,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> additionalTags = const [],
  }) {
    return EasySEOHeaderWrapper(
      h1: h1,
      p: p,
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoSection({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOSectionWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoArticle({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOArticleWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoMain({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOMainWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoList({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOListWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoListItem({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOListItemWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoHtml({
    String? globalName,
    List<SEOHtml> additionalTags = const [],
  }) {
    return EasySEOCustomWrapper(
      tag: "",
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoProduct(
    String productName,
    {
      String? path,
      SEOHtml Function(String? content, {Map<String, String>? attributes,List<SEOHtml> children,}) headingBuilder = SEOHtml.h1,
      List<SEOHtml> additionalTags = const [],
      String? globalName,
    }
  ) {
    return EasySEOArticleWrapper(
      attributes: const {'itemscope': null, 'itemtype': "https://schema.org/Product"},
      jsonLd: {
        '@type': 'Product',
        'name': productName,
      },
      globalName: globalName,
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

  Widget easySeoBrand(String brandName, {String? globalName}) {
    return EasySEOTextWrapper(
      attributes: const {'itemprop': "brand"},
      jsonLd: {
        '@type': 'Brand',
        'name': brandName,
      },
      globalName: globalName,
      child: this,
    );
  }

  Widget easySeoImage({String? name, String? url, String? globalName}) {
    return EasySEOImageWrapper(alt: name, src: url, attributes: {'itemprop': "image"}, globalName: globalName, child: this);
  }

  Widget easySeoAside({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOAsideWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoContainer({String tag = 'div', String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOContainerWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoFigure({String? caption, String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOFigureWrapper(
      caption: caption,
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoForm({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOFormWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoFooter({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOFooterWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoNav({String? label, bool isBreadcrumb = false, String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEONavWrapper(
      label: label,
      isBreadcrumb: isBreadcrumb,
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget easySeoTime({required DateTime dateTime, String? text, String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> additionalTags = const []}) {
    return EasySEOTimeWrapper(
      dateTime: dateTime,
      text: text,
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }
}
