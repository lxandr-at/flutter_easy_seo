part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Recursively walks a Flutter widget tree to produce SEO-optimised HTML.
///
/// The traversal depth-first visits every [Element] starting from a root,
/// identifies [EasySEOWrapper] widgets, resolves globally-registered widgets
/// (see [EasySEOBaseWrapper.globalName]), merges wrapper-level attributes and
/// JSON-LD with element-level values, collects navigation items from
/// [EasySeoNavAnchorWrapper] nodes, and bubbles heading priority from children
/// up to parents so that section-level wrappers reflect the most prominent
/// heading they contain.
///
/// Results are sorted so that footers appear last, then by heading priority
/// (h1 first), while preserving the original child order within equal groups.
class SEOWidgetTreeProcessor {
  Set<String>? _skipGlobals;

  static const _headingPriority = {
    'h1': 0,
    'h2': 1,
    'h3': 2,
    'h4': 3,
    'h5': 4,
    'h6': 5,
  };

  static Map<String, String> _buildWrapperAttrs(EasySEOBaseWrapper wrapper) {
    final attrs = <String, String>{};
    if (wrapper.className != null) attrs['class'] = wrapper.className!;
    attrs.addAll(wrapper.additionalAttributes);
    if (wrapper.attributes != null) {
      for (final e in wrapper.attributes!.entries) {
        if (e.value != null && e.value!.isNotEmpty) {
          attrs[e.key] = e.value!;
        } else {
          attrs[e.key] = '';
        }
      }
    }
    return attrs;
  }

  static SEOHtml _mergeWrapperAttrs(EasySEOBaseWrapper wrapper, SEOHtml html, BuildContext context) {
    final baseAttrs = _buildWrapperAttrs(wrapper);
    final hasBase = baseAttrs.isNotEmpty;
    final hasHtml = html.attributes != null && html.attributes!.isNotEmpty;
    final mergedAttrs = !hasBase && !hasHtml
        ? null
        : <String, String>{...baseAttrs, ...?html.attributes};

    final mergedJsonLd = html.jsonLd ?? wrapper.jsonLd;

    final resolvedAdditional = wrapper.children.map((t) => t.resolve(context)).toList();
    final headTags = resolvedAdditional.where((t) => _headingPriority.containsKey(t.tag)).toList();
    headTags.sort((a, b) => (_headingPriority[a.tag] ?? 6).compareTo(_headingPriority[b.tag] ?? 6));
    final otherTags = resolvedAdditional.where((t) => !_headingPriority.containsKey(t.tag)).toList();

    return SEOHtml(
      tag: html.tag,
      content: html.content,
      attributes: mergedAttrs,
      children: [
        ...headTags,
        ...html.children,
        ...otherTags,
      ],
      relativePath: html.relativePath,
      jsonLd: mergedJsonLd,
    );
  }

  /// Entry point for widget-tree to HTML conversion.
  ///
  /// Traverses [rootElement] and any named global widgets listed in
  /// [includeGlobals] (looked up from [EasySEOManager.globals]), converts
  /// every [EasySEOWrapper] encountered into its [SEOHtml] representation,
  /// and returns the concatenated HTML string.
  ///
  /// **Parameters**
  ///
  /// * [rootElement] — The root widget element whose tree is walked.
  /// * [includeGlobals] — List of [EasySEOBaseWrapper.globalName] strings.
  ///   Matching globally-registered widgets are processed first, in list order,
  ///   before the main tree is traversed. This allows components rendered
  ///   outside the current page (e.g. a persistent nav or footer) to be
  ///   included in the generated HTML.
  /// * [mode] — Controls the rendering format passed to [SEOHtml.toHtmlString]
  ///   (e.g. microdata only, JSON-LD only, or both).
  ///
  /// **Returns** A complete body-level HTML string with all wrappers resolved.
  String processWidgetTree(Element rootElement, List<String> includeGlobals, {SEORenderMode mode = SEORenderMode.microdataAndJsonLd}) {
    final rootResults = <_BuildResult>[];

    for (final name in includeGlobals) {
      final element = EasySEOManager.instance.globals[name] as Element?;
      if (element != null && element.mounted) {
        rootResults.add(_buildSeoHtml(element));
      }
    }

    _skipGlobals = includeGlobals.toSet();
    rootResults.add(_buildSeoHtml(rootElement));
    _skipGlobals = null;

    rootResults.sort((a, b) => a.order.compareTo(b.order));

    return rootResults.map((r) => r.html.toHtmlString(mode: mode)).join();
  }

  _BuildResult _buildSeoHtml(Element element) {
    final widget = element.widget;

    final childResults = <_BuildResult>[];
    element.visitChildren((child) {
      final childWidget = child.widget;
      if (childWidget is EasySEOBaseWrapper &&
          childWidget.globalName != null &&
          _skipGlobals != null &&
          _skipGlobals!.contains(childWidget.globalName)) {
        return;
      }
      childResults.add(_buildSeoHtml(child));
    });

    final navItems = <SEONavItem>[];
    int bubbledPriority = 6;
    for (final child in childResults) {
      navItems.addAll(child.navItems);
      if (child.priority < bubbledPriority) {
        bubbledPriority = child.priority;
      }
    }

    final sortedChildResults = _sortByPriority(childResults);

    if (widget is EasySEOWrapper) {
      final wrapper = widget as EasySEOWrapper;

      if (wrapper is EasySeoNavAnchorWrapper) {
        navItems.add(SEONavItem(text: wrapper.resolvedText, url: wrapper.path));
      }

      var html = wrapper.toSEOHtml(
        children: sortedChildResults.map((r) => r.html).toList(),
        navItems: navItems,
        context: element,
      );
      if (wrapper is EasySEOBaseWrapper) {
        html = _mergeWrapperAttrs(wrapper, html, element);
      }

      int ownPriority = _headingPriority[html.tag] ?? 6;
      int ownOrder = html.tag == 'footer' ? 1 : 0;
      if (ownPriority < bubbledPriority) {
        bubbledPriority = ownPriority;
      }

      return _BuildResult(
        html,
        wrapper is EasySEONavWrapper ? const [] : navItems,
        bubbledPriority,
        ownOrder,
      );
    }

    return _BuildResult(
      SEOHtml(tag: '', children: sortedChildResults.map((r) => r.html).toList()),
      navItems,
      bubbledPriority,
    );
  }

  static int _compareOrder(_BuildResult a, _BuildResult b) {
    if (a.order != b.order) return a.order.compareTo(b.order);
    if (a.priority != b.priority) return a.priority.compareTo(b.priority);
    return 0;
  }

  static List<_BuildResult> _sortByPriority(List<_BuildResult> nodes) {
    final indexed = List.generate(
      nodes.length,
      (i) => (index: i, node: nodes[i]),
    );

    indexed.sort((a, b) {
      final cmp = _compareOrder(a.node, b.node);
      if (cmp != 0) return cmp;
      return a.index.compareTo(b.index);
    });

    return indexed.map((e) => e.node).toList();
  }
}

class _BuildResult {
  final SEOHtml html;
  final List<SEONavItem> navItems;
  final int priority;
  final int order;

  const _BuildResult(this.html, this.navItems, [this.priority = 6, this.order = 0]);
}

/// Holds the resolved set of `<head>` metadata tags for a single page.
///
/// Produced by [EasySEOManager] during page generation after merging per-page
/// head tags with global head tags. The [headTags] list typically includes
/// canonical URL, hreflang alternates, Open Graph properties, Twitter card
/// meta tags, meta description, and the page title.
class SEOPageMetadata {
  /// The ordered list of head tags to emit inside the `<head>` element.
  final List<EasySEOHeadTag> headTags;

  SEOPageMetadata({this.headTags = const []});

  /// Renders every [headTags] entry to its HTML `<meta>` / `<link>` / `<title>`
  /// string (via [EasySEOHeadTag.toHtml]), each indented by two spaces and
  /// separated by newlines. Returns the result suitable for direct placement
  /// inside `<head>...</head>`.
  String generateMetadata() {
    final buffer = StringBuffer();
    for (final tag in headTags) {
      buffer.write('  ');
      buffer.writeln(tag.toHtml());
    }
    return buffer.toString();
  }
}

/// Minimal utility that wraps pre-generated body content and optional head
/// metadata into a standards-compliant HTML5 document skeleton.
class SEOHtmlDocumentGenerator {
  /// Assembles a complete HTML document string.
  ///
  /// Produces `<!DOCTYPE html>` followed by `<html>`, `<head>` (with charset
  /// and viewport meta tags baked in), and `<body>` containing [bodyContent].
  ///
  /// **Parameters**
  ///
  /// * [bodyContent] — The already-processed body HTML to place inside
  ///   `<body>...</body>`. This is the output of [SEOWidgetTreeProcessor.processWidgetTree].
  /// * [metadata] — Optional string returned by [SEOPageMetadata.generateMetadata]
  ///   to be injected inside `<head>`.
  /// * [lang] — Language attribute on the `<html>` element (default `'en'`).
  static String generateFullDocument({
    required String bodyContent,
    String? metadata,
    String lang = 'en',
  }) {
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="$lang">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1.0">');

    if (metadata != null) {
      buffer.writeln(metadata);
    }

    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.write(bodyContent);
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }
}
