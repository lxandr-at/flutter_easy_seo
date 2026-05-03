part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Extension for Text widgets to add SEO capabilities
extension TextSEO on Text {
  Widget seo({
    SEOTextType textType = SEOTextType.p,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOTextWrapper(
      textType: textType,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }

  Widget get seoH1 => seo(textType: SEOTextType.h1);
  Widget get seoH2 => seo(textType: SEOTextType.h2);
  Widget get seoH3 => seo(textType: SEOTextType.h3);
  Widget get seoH4 => seo(textType: SEOTextType.h4);
  Widget get seoH5 => seo(textType: SEOTextType.h5);
  Widget get seoH6 => seo(textType: SEOTextType.h6);
  Widget get seoP => seo();
}

/// Extension for Container widgets to add SEO capabilities
extension ContainerSEO on Container {
  Widget seo({
    String tag = 'div',
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOContainerWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for Image widgets to add SEO capabilities
extension ImageSEO on Image {
  Widget seo({
    String? src,
    String? alt,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOImageWrapper(
      src: src,
      alt: alt,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for NavigationRail widgets to add SEO capabilities
extension NavigationRailSEO on NavigationRail {
  Widget seo({
    String? label,
    String? className,
    Map<String, String>? attributes,
    String? globalName,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEONavWrapper(
      label: label,
      className: className,
      attributes: attributes,
      globalName: globalName,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for BottomNavigationBar widgets to add SEO capabilities
extension BottomNavigationBarSEO on BottomNavigationBar {
  Widget seo({
    String? label,
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEONavWrapper(
      label: label,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for ListView widgets to add SEO capabilities
extension ListViewSEO on ListView {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOListWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for Column widgets to add SEO capabilities
extension ColumnSEO on Column {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOListWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for Row widgets to add SEO capabilities
extension RowSEO on Row {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOListWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for AppBar widgets to add SEO capabilities
extension AppBarSEO on AppBar {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOHeaderWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for Drawer widgets to add SEO capabilities
extension DrawerSEO on Drawer {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
    List<SEOHtml> additionalTags = const [],
  }) {
    return SEOAsideWrapper(
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for Column widgets to mark as navigation container
extension ColumnNavSEO on Column {
  Widget seoNav(
      {String? label, String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEONavWrapper(
      label: label,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for Row widgets to mark as navigation container
extension RowNavSEO on Row {
  Widget seoNav(
      {String? label, String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEONavWrapper(
      label: label,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}

/// Extension for Flex widgets to mark as navigation container
extension FlexNavSEO on Flex {
  Widget seoNav(
      {String? label, String? className, Map<String, String>? attributes, List<SEOHtml> additionalTags = const []}) {
    return SEONavWrapper(
      label: label,
      className: className,
      attributes: attributes,
      additionalTags: additionalTags,
      child: this,
    );
  }
}
