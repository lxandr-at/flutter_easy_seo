part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Extension for Text widgets to add SEO capabilities
extension TextSEO on Text {
  Widget seo({
    String? tag,
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEOTextWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for Container widgets to add SEO capabilities
extension ContainerSEO on Container {
  Widget seo({
    String tag = 'div',
    String? className,
    Map<String, String>? attributes,
    bool isSection = false,
  }) {
    return SEOContainerWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      isSection: isSection,
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
  }) {
    return SEOImageWrapper(
      src: src,
      alt: alt,
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for NavigationRail widgets to add SEO capabilities
extension NavigationRailSEO on NavigationRail {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEONavigationWrapper(
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for BottomNavigationBar widgets to add SEO capabilities
extension BottomNavigationBarSEO on BottomNavigationBar {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEONavigationWrapper(
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for ListView widgets to add SEO capabilities
extension ListViewSEO on ListView {
  Widget seo({
    String tag = 'ul',
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEOListWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for Column widgets to add SEO capabilities
extension ColumnSEO on Column {
  Widget seo({
    String tag = 'div',
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEOListWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for Row widgets to add SEO capabilities
extension RowSEO on Row {
  Widget seo({
    String tag = 'div',
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEOListWrapper(
      tag: tag,
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for AppBar widgets to add SEO capabilities
extension AppBarSEO on AppBar {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEOHeaderWrapper(
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for Drawer widgets to add SEO capabilities
extension DrawerSEO on Drawer {
  Widget seo({
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEOAsideWrapper(
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}

/// Extension for custom widget mapping
extension CustomSEO on Widget {
  Widget seo({
    Widget Function(BuildContext, Widget)? builder,
    String? tag,
    String? className,
    Map<String, String>? attributes,
  }) {
    return SEOCustomWrapper(
      builder: builder,
      tag: tag,
      className: className,
      attributes: attributes,
      child: this,
    );
  }
}