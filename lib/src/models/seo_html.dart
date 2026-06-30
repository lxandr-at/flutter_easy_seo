part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Represents an HTML element that can be injected into the SEO output
/// without affecting the visual Flutter rendering.
///
/// Use [children] on any SEO wrapper to attach extra semantic HTML
/// alongside the widget's generated tag (e.g. structured-data spans, hidden
/// headings that live in a different part of the widget tree, etc.).
///
/// Example:
/// ```dart
/// EasySEOSectionWrapper(
///   children: [
///     SEOHtml(tag: 'h2', content: 'Section Subtitle'),
///     SEOHtml(
///       tag: 'script',
///       attributes: {'type': 'application/ld+json'},
///       content: '{"@type":"Article"}',
///     ),
///   ],
///   child: myWidget,
/// )
/// ```
class SEOHtml {
  final String tag;
  final String? content;
  final Map<String, String>? attributes;
  final List<SEOHtml> children;
  final String? relativePath;
  final Map<String, dynamic>? jsonLd;

  const SEOHtml({
    required this.tag,
    this.content,
    this.attributes,
    this.children = const [],
    this.relativePath,
    this.jsonLd,
  });

  // HTML void elements
  static const _voidElements = {
    'area', 'base', 'br', 'col', 'embed', 'hr', 'img',
    'input', 'link', 'meta', 'param', 'source', 'track', 'wbr',
  };

  bool get _isVoid => _voidElements.contains(tag);

  bool get _hasRealChildren {
    for (final child in children) {
      if (child.tag.isNotEmpty || child.content != null || child._hasRealChildren) return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // HTML rendering
  // ---------------------------------------------------------------------------

  String toHtmlString({
    int indentLevel = 0,
    SEORenderMode mode = SEORenderMode.microdataAndJsonLd,
  }) {
    switch (mode) {
      case SEORenderMode.jsonLdOnly:
        return _jsonLdScripts(indentLevel: indentLevel);
      case SEORenderMode.full:
      case SEORenderMode.microdataAndJsonLd: {
        final tree = _withMicrodata(useMicrodataAttrs: mode == SEORenderMode.microdataAndJsonLd);
        final html = tree._renderHtml(indentLevel: indentLevel);
        // JSON-LD scripts are generated from the ORIGINAL tree's jsonLd fields,
        // NOT from the _withMicrodata-modified tree (which has generated children
        // that would duplicate data already present in parent jsonLd).
        final scripts = _jsonLdScripts(indentLevel: indentLevel);
        return scripts.isNotEmpty ? '$html$scripts' : html;
      }
      case SEORenderMode.microdata:
        return _withMicrodata(useMicrodataAttrs: true)._renderHtml(indentLevel: indentLevel);
      case SEORenderMode.htmlOnly:
        return _withMicrodata(useMicrodataAttrs: false)._renderHtml(indentLevel: indentLevel);
    }
  }

  String _renderHtml({int indentLevel = 0}) {
    final indent = '  ' * indentLevel;
    if (tag.isEmpty) {
      final buffer = StringBuffer();
      if (content != null) {
        buffer.write(indent);
        buffer.writeln(content);
      }
      for (final child in children) {
        buffer.write(child._renderHtml(indentLevel: indentLevel));
      }
      return buffer.toString();
    }

    final buffer = StringBuffer();
    buffer.write(indent);
    buffer.write('<$tag');

    if (attributes != null) {
      for (final entry in attributes!.entries) {
        if (entry.value.isNotEmpty) {
          buffer.write(' ${entry.key}="${_escapeAttr(entry.value)}"');
        } else {
          buffer.write(' ${entry.key}');
        }
      }
    }

    if (_isVoid) {
      buffer.write(' />\n');
      return buffer.toString();
    }

    buffer.write('>');

    final hasSubElements = _hasRealChildren || (content != null && content!.contains('\n'));

    if (hasSubElements) {
      buffer.writeln();
      if (content != null && content!.isNotEmpty) {
        buffer.write('  ' * (indentLevel + 1));
        buffer.writeln(content);
      }
      for (final child in children) {
        buffer.write(child._renderHtml(indentLevel: indentLevel + 1));
      }
      buffer.write(indent);
      buffer.write('</$tag>\n');
    } else {
      if (content != null) {
        buffer.write(content);
      }
      buffer.write('</$tag>\n');
    }

    return buffer.toString();
  }

  String _jsonLdScripts({int indentLevel = 0}) {
    final blocks = toJsonLd();
    if (blocks.isEmpty) return '';
    final indent = '  ' * indentLevel;
    final buffer = StringBuffer();
    buffer.write(indent);
    buffer.write('<script type="application/ld+json">');
    if (blocks.length == 1) {
      buffer.write(jsonEncode(_orderedJsonLd(blocks.first)));
    } else {
      final graph = <String, dynamic>{
        '@context': 'https://schema.org',
        '@graph': [
          for (final block in blocks)
            _orderedJsonLd(
              Map<String, dynamic>.from(block)..remove('@context'),
            ),
        ],
      };
      buffer.write(jsonEncode(_orderedJsonLd(graph)));
    }
    buffer.write('</script>\n');
    return buffer.toString();
  }

  /// Returns a copy of [data] with `@context` and `@type` as the first keys,
  /// and known multi-value fields (`image`, `additionalProperty`) enforced as
  /// arrays.
  /// Strict top-down parsers require these before any other properties.
  static Map<String, dynamic> _orderedJsonLd(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    if (data.containsKey('@context')) {
      result['@context'] = data['@context'];
    }
    if (data.containsKey('@type')) {
      result['@type'] = data['@type'];
    }
    for (final entry in data.entries) {
      if (entry.key == '@context' || entry.key == '@type') continue;
      var value = entry.value;
      if ((entry.key == 'image' || entry.key == 'additionalProperty') &&
          value != null &&
          value is! List) {
        value = [value];
      }
      result[entry.key] = value;
    }
    return result;
  }

  String _escapeAttr(String value) =>
      value.replaceAll('"', '&quot;').replaceAll("'", '&#39;');

  // ---------------------------------------------------------------------------
  // JSON-LD collection — nests children by itemprop into parent block
  // ---------------------------------------------------------------------------

  /// Walks the tree and returns JSON-LD blocks.
  /// Children with `itemprop` + `jsonLd` nest into the parent block.
  /// Children with `jsonLd` but no `itemprop` become independent blocks.
  /// Children with `itemprop` but no `jsonLd` extract value from attrs/content.
  List<Map<String, dynamic>> toJsonLd() {
    final result = <Map<String, dynamic>>[];
    _collectJsonLd(result);
    return result;
  }

  void _collectJsonLd(List<Map<String, dynamic>> result) {
    if (jsonLd != null) {
      final data = Map<String, dynamic>.from(jsonLd!);
      data.putIfAbsent('@context', () => 'https://schema.org');
      _collectChildrenInto(data, result);
      result.add(data);
    } else {
      for (final child in children) {
        child._collectJsonLd(result);
      }
    }
  }

  /// Walks [children] and merges their data into [target] (when they have
  /// an `itemprop`) or adds them to [independents] (when they have `jsonLd`
  /// but no `itemprop`, e.g. `<nav>`).
  void _collectChildrenInto(Map<String, dynamic> target, List<Map<String, dynamic>> independents) {
    for (final child in children) {
      final prop = child.attributes?['itemprop'];

      if (child.jsonLd != null && prop != null && prop.isNotEmpty) {
        // Child has both jsonLd + itemprop → nest into parent under `prop`
        final data = Map<String, dynamic>.from(child.jsonLd!);
        child._collectChildrenInto(data, independents);
        _mergeValue(target, prop, data);
      } else if (child.jsonLd != null) {
        // Child has jsonLd but no itemprop → independent block
        final data = Map<String, dynamic>.from(child.jsonLd!);
        data.putIfAbsent('@context', () => 'https://schema.org');
        child._collectChildrenInto(data, independents);
        independents.add(data);
      } else if (prop != null && prop.isNotEmpty) {
        // Child has itemprop but no jsonLd → extract scalar value from attrs/content
        // BUT only if parent doesn't already have this key (avoid duplicating
        // data already present in the parent's jsonLd, e.g. name from h1).
        if (!target.containsKey(prop)) {
          final value = child._extractMicrodataValue();
          if (value != null) {
            _mergeValue(target, prop, value);
          }
        }
        child._collectChildrenInto(target, independents);
      } else {
        child._collectChildrenInto(target, independents);
      }
    }
  }

  /// Inserts [value] into [target] under [key].
  /// If key already exists → converts to list (for duplicate itemprop).
  void _mergeValue(Map<String, dynamic> target, String key, dynamic value) {
    if (value == null) return;
    if (!target.containsKey(key)) {
      target[key] = value;
    } else {
      final existing = target[key];
      if (existing is List) {
        existing.add(value);
      } else {
        target[key] = [existing, value];
      }
    }
  }

  /// Extracts a scalar value from this HTML element for JSON-LD.
  /// - `<img src="X">` → `'X'`
  /// - `<a href="X">` → `'X'`
  /// - `<meta content="X">` → `'X'`
  /// - `<link href="X">` → `'X'`
  /// - `<span>/<p>/<h1..6>` with content → content
  dynamic _extractMicrodataValue() {
    switch (tag) {
      case 'img':
        return attributes?['src'];
      case 'a':
        return attributes?['href'];
      case 'meta':
        return attributes?['content'];
      case 'link':
        return attributes?['href'];
      default:
        return content;
    }
  }

  // ---------------------------------------------------------------------------
  // Microdata derivation from jsonLd
  // ---------------------------------------------------------------------------

  /// Returns a new [SEOHtml] tree where microdata attributes/children are
  /// derived from each node's [jsonLd] field.
  ///
  /// When [useMicrodataAttrs] is true (microdata/microdataAndJsonLd):
  ///   - Adds `itemscope`/`itemtype` from `@type`
  ///   - Generates `<meta itemprop="X" content="Y">` / `<div itemprop="X">`
  /// When false (full):
  ///   - Converts explicit `itemprop` → `class`, removes `itemscope`/`itemtype`
  ///   - Generates `<span class="X">Y</span>` / `<div class="X">`
  SEOHtml _withMicrodata({bool useMicrodataAttrs = true}) {
    var newAttrs = attributes != null ? Map<String, String>.from(attributes!) : null;

    // 1. Add itemscope / itemtype from jsonLd (only for microdata mode)
    if (useMicrodataAttrs && jsonLd != null && jsonLd!.containsKey('@type')) {
      newAttrs ??= {};
      newAttrs['itemscope'] = '';
      newAttrs['itemtype'] = 'https://schema.org/${jsonLd!['@type']}';
    }

    // 2. Convert explicit itemprop → class in non-microdata mode
    if (!useMicrodataAttrs && newAttrs != null) {
      final itemprop = newAttrs.remove('itemprop');
      if (itemprop != null && !newAttrs.containsKey('class')) {
        newAttrs['class'] = itemprop;
      }
      newAttrs.remove('itemscope');
      newAttrs.remove('itemtype');
      if (newAttrs.isEmpty) newAttrs = null;
    }

    // 3. Generate children from jsonLd
    final generated = <SEOHtml>[];
    if (jsonLd != null) {
      // In full mode, skip for nodes that already have a structural list
      // (e.g. <nav> with <ul>) — the visual tree already renders this content.
      final hasStructuralList = !useMicrodataAttrs &&
          children.any((c) => c.tag == 'ul' || c.tag == 'ol');
      if (!hasStructuralList) {
      for (final entry in jsonLd!.entries) {
        if (entry.key == '@type' || entry.key == '@context') continue;
        // In full mode, skip scalar values already rendered by a child element
        // (e.g. Product.name from <h3 itemprop="name">)
        if (!useMicrodataAttrs &&
            (entry.value is String || entry.value is num || entry.value is bool) &&
            children.any((c) => c.attributes?['itemprop'] == entry.key)) {
          continue;
        }
        generated.addAll(_microdataChildren(entry.key, entry.value, useMicrodataAttrs: useMicrodataAttrs));
      }
      }
    }

    // 4. Recurse on existing children
    final resolvedChildren = <SEOHtml>[];
    for (final child in children) {
      resolvedChildren.add(child._withMicrodata(useMicrodataAttrs: useMicrodataAttrs));
    }
    resolvedChildren.addAll(generated);

    return SEOHtml(
      tag: tag,
      content: (!useMicrodataAttrs && generated.isNotEmpty) ? null : content,
      attributes: newAttrs,
      children: resolvedChildren,
      jsonLd: jsonLd,
    );
  }

  List<SEOHtml> _microdataChildren(String prop, dynamic value, {bool useMicrodataAttrs = true}) {
    if (value is String || value is num || value is bool) {
      final valStr = value.toString();
      // In full mode, skip schema.org reference URLs — no visual purpose
      if (!useMicrodataAttrs && valStr.startsWith('https://schema.org/')) {
        return const [];
      }
      final dt = DateTime.tryParse(valStr);
      if (dt != null) {
        final formatted = '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
        return [
          SEOTime(
            text: formatted,
            dateTime: dt,
            attributes: useMicrodataAttrs ? {'itemprop': prop} : {'class': prop},
          ),
        ];
      }
      if (useMicrodataAttrs) {
        return [SEOMeta(attributes: {'itemprop': prop, 'content': valStr})];
      } else {
        return [SEOSpan(valStr, attributes: {'class': prop})];
      }
    }

    if (value is Map<String, dynamic>) {
      final attrs = useMicrodataAttrs ? {'itemprop': prop} : {'class': prop};
      return [
        SEODiv(
          attributes: attrs,
          jsonLd: value,
        )._withMicrodata(useMicrodataAttrs: useMicrodataAttrs),
      ];
    }

    if (value is List) {
      final items = <SEOHtml>[];
      for (final item in value) {
        if (item is String || item is num || item is bool) {
          final valStr = item.toString();
          if (useMicrodataAttrs) {
            items.add(SEOMeta(attributes: {'itemprop': prop, 'content': valStr}));
          } else {
            items.add(SEOSpan(valStr, attributes: {'class': prop}));
          }
        } else if (item is Map<String, dynamic>) {
          if (useMicrodataAttrs) {
            items.add(
              SEODiv(
                attributes: {if (prop.isNotEmpty) 'itemprop': prop},
                jsonLd: item,
              )._withMicrodata(useMicrodataAttrs: useMicrodataAttrs),
            );
          } else {
            final inner = SEODiv(jsonLd: item)._withMicrodata(useMicrodataAttrs: useMicrodataAttrs);
            items.add(
              SEOListItem(
                attributes: {'class': 'offer-item'},
                children: inner.children,
              ),
            );
          }
        }
      }
      if (!useMicrodataAttrs && items.isNotEmpty && value.any((v) => v is Map)) {
        return [
          SEOUnorderedList(
            attributes: {'class': '$prop-list'},
            children: items,
          ),
        ];
      }
      return items;
    }

    return const [];
  }

  // ---------------------------------------------------------------------------
  // Convenience constructors with jsonLd
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Path resolution
  // ---------------------------------------------------------------------------

  SEOHtml resolve(BuildContext context) {
    String? resolvedHref;
    Map<String, String>? resolvedAttributes = attributes != null ? Map.from(attributes!) : null;

    if (relativePath != null) {
      final currentPath = EasySEOManager.instance.getCurrentPath(context);
      final urls = EasySEOManager.instance.resolveSeoUrls(currentPath);
      final baseUrl = urls.canonicalUrl;
      final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final cleanPath = relativePath!.startsWith('/') ? relativePath! : '/$relativePath';
      resolvedHref = '$cleanBase$cleanPath';

      resolvedAttributes ??= {};
      resolvedAttributes['href'] = resolvedHref;
    }

    final resolvedChildren = children.map((c) => c.resolve(context)).toList();

    return SEOHtml(
      tag: tag,
      content: content,
      attributes: resolvedAttributes,
      children: resolvedChildren,
      relativePath: relativePath,
      jsonLd: jsonLd,
    );
  }
}

/// Controls which output format(s) [SEOHtml.toHtmlString] produces.
enum SEORenderMode {
  /// Clean HTML — no schema attributes, no JSON-LD script tags.
  htmlOnly,

  /// HTML with microdata attributes derived from [SEOHtml.jsonLd].
  microdata,

  /// Only JSON-LD `<script>` tags, no body HTML.
  jsonLdOnly,

  /// Clean HTML + JSON-LD script tags.
  full,

  /// HTML with microdata attributes + JSON-LD script tags.
  microdataAndJsonLd,
}

/// Represents an item in a navigation menu for JSON-LD generation
class SEONavItem {
  final String text;
  final String url;

  const SEONavItem({required this.text, required this.url});
}

/// Represents a single question/answer pair for [EasySEOFaqWrapper].
class EasySEOFaqItem {
  final String question;
  final String answer;

  const EasySEOFaqItem({required this.question, required this.answer});
}

extension SEOHtmlJsonLd on SEOHtml {
  /// Returns a SiteNavigationElement JSON-LD map.
  static Map<String, dynamic> siteNavigationData(List<SEONavItem> items) {
    return {
      '@type': 'ItemList',
      'numberOfItems': items.length,
      'itemListElement': items
        .asMap()
        .entries
        .map((e) {
            return {
              '@type': 'ListItem',
              'position': e.key + 1,
              'item': {
                '@type': 'SiteNavigationElement',
                'name': e.value.text,
                'url': EasySEOManager.instance.formatFullUrl(e.value.url),
              },
            };
          })
        .toList(),
    };
  }

  /// Returns a BreadcrumbList JSON-LD map.
  static Map<String, dynamic> breadcrumbListData(List<SEONavItem> items) {
    return {
      '@type': 'BreadcrumbList',
      'itemListElement': items
          .asMap()
          .entries
          .map((e) => {
            '@type': 'ListItem',
            'position': e.key + 1,
            'name': e.value.text,
            if (e.value.url.isNotEmpty) 'item': EasySEOManager.instance.formatFullUrl(e.value.url),
          },
        ).toList(),
    };
  }

  /// Generates a Service JSON-LD content string.
  static String service(SEOServiceInfo info) {
    final data = {
      '@context': 'https://schema.org',
      '@type': 'Service',
      'mainEntityOfPage': {'@type': 'WebPage'},
      'serviceType': info.serviceType,
      'provider': {
        '@type': 'Organization',
        'name': info.providerName,
        'logo': info.brandLogoUrl,
        if (info.providerUrl != null) 'url': info.providerUrl,
      },
      'areaServed': info.areasServed.map((area) => {'@type': 'Country', 'name': area}).toList(),
    };

    return jsonEncode(data);
  }

}
