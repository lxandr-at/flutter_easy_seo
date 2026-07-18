part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Interface for anything that can contribute one or more [EasySEOHeadTag]s.
abstract class EasySEOHeadTagSource {
  List<EasySEOHeadTag> toHeadTags();
}

/// Base class for any tag inside the `<head>` section.
abstract class EasySEOHeadTag implements EasySEOHeadTagSource {
  final String tagName;
  final Map<String, String> attributes;

  const EasySEOHeadTag(this.tagName, this.attributes);

  /// Returns a unique identifier for this tag type (e.g., "meta:description")
  /// to prevent duplicates in the `<head>` section.
  String get key {
    final String? name = attributes['name'];
    final String? property = attributes['property'];
    final String? rel = attributes['rel'];
    final String? content = attributes['content'];

    if (tagName == 'title') return 'title';
    if (tagName == 'script') return 'script:${attributes['type'] ?? 'no-type'}:$hashCode';

    // 1. Handle Multi-value Link tags (rel="alternate")
    if (rel == 'alternate') {
      return 'link:alternate:${attributes['hreflang'] ?? attributes['href']}';
    }

    // 2. Handle Multi-value Meta tags (og:image, og:video, etc.)
    // These properties are allowed to have multiple entries in the <head>
    const multiValueProperties = {'og:image', 'og:video', 'og:audio', 'twitter:image'};
    if (property != null && multiValueProperties.contains(property)) {
      return 'meta:property:$property:$content';
    }
    if (name != null && multiValueProperties.contains(name)) {
      return 'meta:name:$name:$content';
    }

    // 3. Standard Deduplication (Single-value tags)
    if (name != null) return 'meta:name:$name';
    if (property != null) return 'meta:property:$property';
    if (rel != null) return 'link:rel:$rel';
    if (attributes.containsKey('charset')) return 'meta:charset';

    // Fallback for custom tags
    return '$tagName:${attributes.hashCode}';
  }

  // HTML "Void" elements don't have closing tags
  bool get isVoid => tagName == 'meta' || tagName == 'link';

  String _escapeHtml(String value) {
    return value.replaceAll('"', '&quot;').replaceAll("'", '&#39;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  }

  String toHtml() {
    // 1. Prepare the library identifier
    // We use a data attribute because it's standard for metadata scripts
    final libAttr = 'data-easy-seo="${_escapeHtml(key)}"';

    // 2. Prepare the specific attributes (name, content, etc.)
    final attrs = attributes.entries.map((e) => '${e.key}="${_escapeHtml(e.value)}"').join(' ');

    // 3. Combine them
    final allAttrs = attrs.isEmpty ? libAttr : '$libAttr $attrs';

    final openTag = '<$tagName $allAttrs>';

    return isVoid ? openTag : '$openTag</$tagName>';
  }

  @override
  List<EasySEOHeadTag> toHeadTags() => [this];
}

class EasySEOTitleTag extends EasySEOHeadTag {
  final String title;
  // Title tags don't usually have attributes, so we pass an empty map
  const EasySEOTitleTag(this.title) : super('title', const {});

  @override
  String toHtml() {
    return '<title data-easy-seo="title">$title</title>';
  }
}

/// Flexible Model for Meta tags
class EasySEOMetaTag extends EasySEOHeadTag {
  EasySEOMetaTag(Map<String, String> attributes) : super('meta', attributes);

  // --- Standard SEO Factories ---
  factory EasySEOMetaTag.title(String content) => EasySEOMetaTag({'name': 'title', 'content': content});
  factory EasySEOMetaTag.description(String content) => EasySEOMetaTag({'name': 'description', 'content': content});
  factory EasySEOMetaTag.keywords(List<String> keywords) =>
      EasySEOMetaTag({'name': 'keywords', 'content': keywords.join(', ')});
  factory EasySEOMetaTag.viewport({String content = 'width=device-width, initial-scale=1.0'}) =>
      EasySEOMetaTag({'name': 'viewport', 'content': content});
  factory EasySEOMetaTag.charset({String charset = 'UTF-8'}) => EasySEOMetaTag({'charset': charset});
  factory EasySEOMetaTag.author(String name) => EasySEOMetaTag({'name': 'author', 'content': name});
  factory EasySEOMetaTag.themeColor(String colorHex) => EasySEOMetaTag({'name': 'theme-color', 'content': colorHex});
  factory EasySEOMetaTag.robots({bool index = true, bool follow = true}) => EasySEOMetaTag(
        {'name': 'robots', 'content': '${index ? 'index' : 'noindex'}, ${follow ? 'follow' : 'nofollow'}'},
      );

  // --- Apple & PWA Factories ---
  factory EasySEOMetaTag.appleMobileWebAppCapable({bool capable = true}) =>
      EasySEOMetaTag({'name': 'mobile-web-app-capable', 'content': capable ? 'yes' : 'no'});
  factory EasySEOMetaTag.appleStatusBarStyle({String style = 'black-translucent'}) =>
      EasySEOMetaTag({'name': 'apple-mobile-web-app-status-bar-style', 'content': style});
  factory EasySEOMetaTag.appleWebAppTitle(String title) =>
      EasySEOMetaTag({'name': 'apple-mobile-web-app-title', 'content': title});
}

/// Open Graph meta tags. Each non-null parameter produces a `<meta property="og:...">` tag.
class EasySEOOgTags implements EasySEOHeadTagSource {
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? url;
  final String? type;
  final String? siteName;

  const EasySEOOgTags({
    this.title,
    this.description,
    this.imageUrl,
    this.url,
    this.type,
    this.siteName,
  });

  @override
  List<EasySEOHeadTag> toHeadTags() {
    final tags = <EasySEOHeadTag>[];
    if (title != null) tags.add(EasySEOMetaTag({'property': 'og:title', 'content': title!}));
    if (description != null) tags.add(EasySEOMetaTag({'property': 'og:description', 'content': description!}));
    if (imageUrl != null) tags.add(EasySEOMetaTag({'property': 'og:image', 'content': imageUrl!}));
    if (url != null) tags.add(EasySEOMetaTag({'property': 'og:url', 'content': url!}));
    if (type != null) tags.add(EasySEOMetaTag({'property': 'og:type', 'content': type!}));
    if (siteName != null) tags.add(EasySEOMetaTag({'property': 'og:site_name', 'content': siteName!}));
    return tags;
  }
}

/// Twitter Card meta tags. Each non-null parameter produces a `<meta name="twitter:...">` tag.
class EasySEOTwitterTags implements EasySEOHeadTagSource {
  final String? card;
  final String? site;
  final String? title;
  final String? description;
  final String? image;

  const EasySEOTwitterTags({
    this.card = 'summary_large_image',
    this.site,
    this.title,
    this.description,
    this.image,
  });

  @override
  List<EasySEOHeadTag> toHeadTags() {
    final tags = <EasySEOHeadTag>[];
    if (card != null) tags.add(EasySEOMetaTag({'name': 'twitter:card', 'content': card!}));
    if (site != null) tags.add(EasySEOMetaTag({'name': 'twitter:site', 'content': site!}));
    if (title != null) tags.add(EasySEOMetaTag({'name': 'twitter:title', 'content': title!}));
    if (description != null) tags.add(EasySEOMetaTag({'name': 'twitter:description', 'content': description!}));
    if (image != null) tags.add(EasySEOMetaTag({'name': 'twitter:image', 'content': image!}));
    return tags;
  }
}

class EasySEOLinkTag extends EasySEOHeadTag {
  EasySEOLinkTag(Map<String, String> attributes) : super('link', attributes);

  /// Standard factory for any link tag
  factory EasySEOLinkTag.custom({
    required String rel,
    required String href,
    String? hreflang,
    String? type,
  }) {
    return EasySEOLinkTag({
      'rel': rel,
      'href': href,
      if (hreflang != null) 'hreflang': hreflang,
      if (type != null) 'type': type,
    });
  }

  /// The "Master" version of a URL (Crucial for SEO)
  factory EasySEOLinkTag.canonical(String href) => EasySEOLinkTag({'rel': 'canonical', 'href': href});

  /// For multilingual support
  factory EasySEOLinkTag.alternate({required String href, required String lang}) =>
      EasySEOLinkTag({'rel': 'alternate', 'href': href, 'hreflang': lang});

  /// For site icons - handles .ico, .png, and .svg
  factory EasySEOLinkTag.icon(String href, {String? type}) {
    final cleanHref = href.startsWith('/') ? href : '/$href';
    // Logic to guess the type if not provided
    String effectiveType =
        type ?? (cleanHref.endsWith('.svg') ? 'image/svg+xml' : 'image/png');
    if (cleanHref.endsWith('.ico')) effectiveType = 'image/x-icon';

    return EasySEOLinkTag({
      'rel': 'icon',
      'href': cleanHref,
      'type': effectiveType,
    });
  }

  /// For PWA manifest
  factory EasySEOLinkTag.manifest(String href) {
    final cleanHref = href.startsWith('/') ? href : '/$href';
    return EasySEOLinkTag({'rel': 'manifest', 'href': cleanHref});
  }

  /// For Apple touch icon
  factory EasySEOLinkTag.appleTouchIcon(String href) {
    final cleanHref = href.startsWith('/') ? href : '/$href';
    return EasySEOLinkTag({'rel': 'apple-touch-icon', 'href': cleanHref});
  }
}

class EasySEOScriptTag extends EasySEOHeadTag {
  final String content;

  EasySEOScriptTag(this.content, {Map<String, String> attributes = const {'type': 'application/ld+json'}})
      : super('script', attributes);

  @override
  String toHtml() {
    final libAttr = 'data-easy-seo="${_escapeHtml(key)}"';
    final attrs = attributes.entries.map((e) => '${e.key}="${_escapeHtml(e.value)}"').join(' ');
    final allAttrs = attrs.isEmpty ? libAttr : '$libAttr $attrs';
    return '<script $allAttrs>$content</script>';
  }
}

class SEOServiceInfo implements EasySEOHeadTagSource {
  final String serviceType;
  final String providerName;
  final String brandLogoUrl;
  final List<String> areasServed;
  final String? providerUrl;

  const SEOServiceInfo({
    required this.serviceType,
    required this.providerName,
    required this.brandLogoUrl,
    required this.areasServed,
    this.providerUrl,
  });

  SEOServiceInfo copyWith({
    String? serviceType,
    String? providerName,
    String? brandLogoUrl,
    List<String>? areasServed,
    String? providerUrl,
  }) {
    return SEOServiceInfo(
      serviceType: serviceType ?? this.serviceType,
      providerName: providerName ?? this.providerName,
      brandLogoUrl: brandLogoUrl ?? this.brandLogoUrl,
      areasServed: areasServed ?? this.areasServed,
      providerUrl: providerUrl ?? this.providerUrl,
    );
  }

  @override
  List<EasySEOHeadTag> toHeadTags() =>
      [EasySEOScriptTag(SEOHtmlJsonLd.service(this))];
}

/// Bundle of common Apple PWA head tags.
class EasySEOAppleHeadTags implements EasySEOHeadTagSource {
  final String title;
  final String iconUrl;
  final String statusBarStyle;
  final bool isWebAppCapable;

  const EasySEOAppleHeadTags({
    required this.title,
    required this.iconUrl,
    this.statusBarStyle = 'black-translucent',
    this.isWebAppCapable = true,
  });

  @override
  List<EasySEOHeadTag> toHeadTags() => [
        EasySEOMetaTag.appleWebAppTitle(title),
        EasySEOLinkTag.appleTouchIcon(iconUrl),
        EasySEOMetaTag.appleMobileWebAppCapable(capable: isWebAppCapable),
        EasySEOMetaTag.appleStatusBarStyle(style: statusBarStyle),
      ];
}
