part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Extension for Text widgets to add SEO capabilities
extension TextSEO on Text {
  Widget easySeo({
    SEOTextType textType = SEOTextType.p,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOTextWrapper(
      textType: textType,
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }

  Widget get easySeoH1 => easySeo(textType: SEOTextType.h1);
  Widget get easySeoH2 => easySeo(textType: SEOTextType.h2);
  Widget get easySeoH3 => easySeo(textType: SEOTextType.h3);
  Widget get easySeoH4 => easySeo(textType: SEOTextType.h4);
  Widget get easySeoH5 => easySeo(textType: SEOTextType.h5);
  Widget get easySeoH6 => easySeo(textType: SEOTextType.h6);
  Widget get easySeoP => easySeo();
}

/// Extension for Container widgets to add SEO capabilities
extension ContainerSEO on Container {
  Widget easySeo({
    String tag = 'div',
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOContainerWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}

/// Extension for Image widgets to add SEO capabilities
extension ImageSEO on Image {
  Widget easySeo({
    String? src,
    String? alt,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOImageWrapper(
      src: src,
      alt: alt,
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}

/// Extension for NavigationRail widgets to add SEO capabilities
extension NavigationRailSEO on NavigationRail {
  Widget easySeo({
    bool isBreadcrumb = false,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> children = const [],
  }) {
    return EasySEONavWrapper(
      isBreadcrumb: isBreadcrumb,
      className: className,
      attributes: attributes,
      globalName: globalName,
      children: children,
      child: this,
    );
  }
}

/// Extension for BottomNavigationBar widgets to add SEO capabilities
extension BottomNavigationBarSEO on BottomNavigationBar {
  Widget easySeo({
    bool isBreadcrumb = false,
    String? globalName,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEONavWrapper(
      isBreadcrumb: isBreadcrumb,
      globalName: globalName,
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}

/// Extension for BottomNavigationBar widgets to add SEO capabilities
extension NavigationBarSEO on NavigationBar {
  Widget easySeo({
    bool isBreadcrumb = false,
    String? globalName,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEONavWrapper(
      isBreadcrumb: isBreadcrumb,
      globalName: globalName,
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}

/// Extension for ListView widgets to add SEO capabilities
extension ListViewSEO on ListView {
  Widget easySeo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOListWrapper(
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}

/// Extension for Column widgets to add SEO capabilities
extension ColumnSEO on Column {
  Widget easySeo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOListWrapper(
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}

/// Extension for Row widgets to add SEO capabilities
extension RowSEO on Row {
  Widget easySeo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOListWrapper(
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}

/// Extension for AppBar widgets to add SEO capabilities
extension AppBarSEO on AppBar {
  Widget easySeo({
    String? h1,
    String? p,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOHeaderWrapper(
      h1: h1,
      p: p,
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}

/// Extension for Drawer widgets to add SEO capabilities
extension DrawerSEO on Drawer {
  Widget easySeo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> children = const [],
  }) {
    return EasySEOAsideWrapper(
      className: className,
      attributes: attributes,
      children: children,
      child: this,
    );
  }
}
