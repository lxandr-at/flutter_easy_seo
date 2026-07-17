part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Extension methods on [Widget] to wrap widgets with SEO-aware semantic HTML containers.
extension EasySEOWidgetExtension on Widget {
  /// Wraps this widget in a generic HTML container (`<div>` by default) with
  /// optional attributes, JSON-LD children, and a global name for cross-page inclusion.
  Widget easySeo({
    String? tag,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOContainerWrapper(
      tag: tag ?? 'div',
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Exposes this widget's content as a semantic HTML text element (`<p>`,
  /// `<h1>`–`<h6>`) specified by [textType].
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

  /// Shortcut for [easySeoText] with [SEOTextType.h1]. Emits `<h1>`.
  Widget easySeoH1({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h1, text: text, globalName: globalName, children: children);
  /// Shortcut for [easySeoText] with [SEOTextType.h2]. Emits `<h2>`.
  Widget easySeoH2({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h2, text: text, globalName: globalName, children: children);
  /// Shortcut for [easySeoText] with [SEOTextType.h3]. Emits `<h3>`.
  Widget easySeoH3({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h3, text: text, globalName: globalName, children: children);
  /// Shortcut for [easySeoText] with [SEOTextType.h4]. Emits `<h4>`.
  Widget easySeoH4({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h4, text: text, globalName: globalName, children: children);
  /// Shortcut for [easySeoText] with [SEOTextType.h5]. Emits `<h5>`.
  Widget easySeoH5({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h5, text: text, globalName: globalName, children: children);
  /// Shortcut for [easySeoText] with [SEOTextType.h6]. Emits `<h6>`.
  Widget easySeoH6({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.h6, text: text, globalName: globalName, children: children);
  /// Shortcut for [easySeoText] with [SEOTextType.p]. Emits `<p>`.
  Widget easySeoP({String? text, String? globalName, List<SEOHtml> children = const []}) =>
      easySeoText(textType: SEOTextType.p, text: text, globalName: globalName, children: children);

  /// Wraps this widget in an `<a>` anchor tag pointing to [path].
  Widget easySeoAnchor({
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

  /// Wraps this widget in a navigation `<a>` anchor, intended for use inside
  /// [easySeoNav] or breadcrumb contexts.
  Widget easySeoNavAnchor({
    required String path,
    String? text,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySeoNavAnchorWrapper(
      path: path,
      text: text,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Wraps this widget in a `<header>` element with optional `<h1>` and `<p>`
  /// children for page-level identification.
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

  /// Wraps this widget in a `<section>` element with optional JSON-LD structured data.
  Widget easySeoSection({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const [], Map<String, dynamic>? jsonLd}) {
    return EasySEOSectionWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      jsonLd: jsonLd,
      child: this,
    );
  }

  /// Wraps this widget in an `<article>` element with optional JSON-LD structured
  /// data (e.g. `@type: Product`, `@type: WebPage`).
  Widget easySeoArticle({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const [], Map<String, dynamic>? jsonLd}) {
    return EasySEOArticleWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      jsonLd: jsonLd,
      child: this,
    );
  }

  /// Wraps this widget in a `<main>` element, denoting the primary content of the page.
  Widget easySeoMain({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const [], Map<String, dynamic>? jsonLd}) {
    return EasySEOMainWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      jsonLd: jsonLd,
      child: this,
    );
  }

  /// Wraps this widget in a `<ul>` element. Use [easySeoListItem] on individual children.
  Widget easySeoList({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOListWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Wraps this widget in an `<li>` element, intended as a child of [easySeoList].
  Widget easySeoListItem({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOListItemWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Attaches custom [SEOHtml] child nodes to this widget without generating an
  /// extra wrapper tag.
  Widget easySeoHtml({
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOContainerWrapper(
      tag: "",
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Wraps this widget in an `<article>` with `itemscope="Product"` and generates
  /// a `@type: Product` JSON-LD stanza.
  Widget easySeoProduct(
    String productName,
    {
      String? path,
      SEOHtml Function(String content, {Map<String, String>? attributes, List<SEOHtml> children, Map<String, dynamic>? jsonLd}) headingBuilder = SEOH1.new,
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
                SEOAnchor(content: productName, relativePath: path, attributes: {'itemprop': "url"}),
            ],
        ),
        ...children,
      ],
      child: this,
    );
  }

  /// Wraps this widget in a `<span>` with `itemprop="brand"` and a
  /// `@type: Brand` JSON-LD stanza.
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

  /// Wraps this widget with `itemprop="image"` attributes for image markup in
  /// structured data contexts.
  Widget easySeoImage({String? name, String? url, String? globalName}) {
    return EasySEOImageWrapper(alt: name, src: url, attributes: {'itemprop': "image"}, globalName: globalName, child: this);
  }

  /// Wraps this widget in an `<aside>` element for tangential or sidebar content.
  Widget easySeoAside({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOAsideWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Wraps this widget in a generic HTML element with a configurable [tag] name
  /// (e.g. `<div>`, `<span>`).
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

  /// Wraps this widget in a `<figure>` element with an optional `<figcaption>`.
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

  /// Wraps this widget in a `<form>` element.
  Widget easySeoForm({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOFormWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Wraps this widget in a `<footer>` element.
  Widget easySeoFooter({String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOFooterWrapper(
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Wraps this widget in a `<nav>` element. Set [isBreadcrumb] to `true` for
  /// breadcrumb-style ARIA and JSON-LD `BreadcrumbList` output.
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

  /// Wraps this widget in a `<section>` with FAQPage structured data. Each
  /// [items] entry generates a Question + Answer pair.
  Widget easySeoFaq({required List<EasySEOFaqItem> items, String? className, Map<String, String>? attributes, String? globalName, List<SEOHtml> children = const []}) {
    return EasySEOFaqWrapper(
      items: items,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }

  /// Wraps this widget in a `<time>` element with a machine-readable [dateTime] attribute.
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
