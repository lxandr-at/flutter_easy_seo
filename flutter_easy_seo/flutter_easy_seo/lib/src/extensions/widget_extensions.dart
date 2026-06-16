part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Extension for custom widget mapping
extension EasySEOWidgetExtension on Widget {
  Widget easySeo({
    Widget Function(BuildContext, Widget)? builder,
    String? tag,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOCustomWrapper(
      builder: builder,
      tag: tag,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoText({
    SEOTextType textType = SEOTextType.p,
    String? className,
    Map<String, String>? attributes,
    String? text,
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOTextWrapper(
      textType: textType,
      className: className,
      attributes: attributes,
      text: text,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoH1({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h1, text: text, globalName: globalName, children: children);
  Widget easySeoH2({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h2, text: text, globalName: globalName, children: children);
  Widget easySeoH3({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h3, text: text, globalName: globalName, children: children);
  Widget easySeoH4({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h4, text: text, globalName: globalName, children: children);
  Widget easySeoH5({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h5, text: text, globalName: globalName, children: children);
  Widget easySeoH6({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h6, text: text, globalName: globalName, children: children);
  Widget easySeoP({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.p, text: text, globalName: globalName, children: children);

  Widget easySeoLink({
    required String path,
    String? text,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOLinkWrapper(
      path: path,
      text: text,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoNavLink({
    required String path,
    String? text,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEONavLinkWrapper(
      path: path,
      text: text,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoHeader({
    String? h1,
    String? p,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOHeaderWrapper(
      h1: h1,
      p: p,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoSection({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOSectionWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoArticle({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOArticleWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoMain({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOMainWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoList({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOListWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoListItem({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOListItemWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoHtml({
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOCustomWrapper(
      tag: "",
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoProduct(
    String productName,
    {
      String? path,
      SEOHtml Function(String? content, {Map<String, String>? attributes,List<SEOHtml> children,}) headingBuilder = SEOHtml.h1,
      List<SEOHtml> children = const [],
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
      children: [
        headingBuilder(
            path == null ? productName : '',
            attributes: {'itemprop': "name"},
            children: [
              if (path != null)
                SEOHtml.a(content: productName, relativePath: path, attributes: {'itemprop': "url"})
            ]),
        ...children
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

  Widget easySeoAside({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOAsideWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoContainer({String tag = 'div', String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOContainerWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoFigure({String? caption, String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOFigureWrapper(
      caption: caption,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoForm({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOFormWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoFooter({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOFooterWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoNav({bool isBreadcrumb = false, String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEONavWrapper(
      isBreadcrumb: isBreadcrumb,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  Widget easySeoTime({required DateTime dateTime, String? text, String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOTimeWrapper(
      dateTime: dateTime,
      text: text,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }
}
