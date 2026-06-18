part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOWidgetTreeProcessor {
  SEOPageMetadata? _metadata;
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

  String processWidgetTree(Element rootElement, List<String> includeGlobals, {SEORenderMode mode = SEORenderMode.microdataAndJsonLd}) {
    _metadata = null;

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

  SEOPageMetadata? get metadata => _metadata;

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

      if (wrapper is easySeoNavAnchorWrapper) {
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
      for (final child in html.children) {
        final childPrio = _headingPriority[child.tag];
        if (childPrio != null && childPrio < ownPriority) {
          ownPriority = childPrio;
        }
      }
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

class SEOPageMetadata {
  final List<EasySEOHeadTag> headTags;

  SEOPageMetadata({this.headTags = const []});

  String generateMetadata() {
    final buffer = StringBuffer();
    for (final tag in headTags) {
      buffer.write('  ');
      buffer.writeln(tag.toHtml());
    }
    return buffer.toString();
  }
}

class SEOHtmlDocumentGenerator {
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
