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

  String processWidgetTree(Element rootElement, List<String> includeGlobals, {SEORenderMode mode = SEORenderMode.microdataAndJsonLd}) {
    _metadata = null;

    final roots = <SEOHtml>[];

    for (final name in includeGlobals) {
      final element = EasySEOManager.instance.globals[name] as Element?;
      if (element != null && element.mounted) {
        roots.add(_buildSeoHtml(element).html);
      }
    }

    _skipGlobals = includeGlobals.toSet();
    roots.add(_buildSeoHtml(rootElement).html);
    _skipGlobals = null;

    return roots.map((r) => r.toHtmlString(mode: mode)).join();
  }

  SEOPageMetadata? get metadata => _metadata;

  _BuildResult _buildSeoHtml(Element element) {
    final widget = element.widget;

    final childResults = <_BuildResult>[];
    element.visitChildren((child) {
      final childWidget = child.widget;
      if (childWidget is BaseSEOWrapper &&
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

    if (widget is SEOWrapper) {
      final wrapper = widget as SEOWrapper;

      if (wrapper is SEONavLinkWrapper) {
        navItems.add(SEONavItem(text: wrapper.text ?? '', url: wrapper.path));
      }

      final html = wrapper.toSEOHtml(
        children: sortedChildResults.map((r) => r.html).toList(),
        navItems: navItems,
        context: element,
      );

      int ownPriority = _headingPriority[html.tag] ?? 6;
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
        wrapper is SEONavWrapper ? const [] : navItems,
        bubbledPriority,
      );
    }

    return _BuildResult(
      SEOHtml(tag: '', children: sortedChildResults.map((r) => r.html).toList()),
      navItems,
      bubbledPriority,
    );
  }

  static List<_BuildResult> _sortByPriority(List<_BuildResult> nodes) {
    final indexed = List.generate(
      nodes.length,
      (i) => (index: i, node: nodes[i]),
    );

    indexed.sort((a, b) {
      if (a.node.priority != b.node.priority) return a.node.priority.compareTo(b.node.priority);
      return a.index.compareTo(b.index);
    });

    return indexed.map((e) => e.node).toList();
  }
}

class _BuildResult {
  final SEOHtml html;
  final List<SEONavItem> navItems;
  final int priority;

  const _BuildResult(this.html, this.navItems, [this.priority = 6]);
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
