part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOWidgetTreeProcessor {
  SEOPageMetadata? _metadata;

  /// Priority order for heading tags. Lower value = output first.
  static const _headingPriority = {
    'h1': 0,
    'h2': 1,
    'h3': 2,
    'h4': 3,
    'h5': 4,
    'h6': 5,
  };

  String processWidgetTree(Element rootElement, List<String> includeGlobals) {
    _metadata = null;

    final roots = <_HtmlNode>[];

    // add widget info from outside of the root
    for (var name in includeGlobals) {
      final element = EasySEOConfig.instance.globals[name] as Element?;
      if (element != null && element.mounted) {
        roots.add(_buildNode(element, 0));
      }
    }

    roots.add(_buildNode(rootElement, 0));

    final buffer = StringBuffer();
    for (final node in roots) {
      _serialize(node, buffer);
    }
    return buffer.toString();
  }

  SEOPageMetadata? get metadata => _metadata;

  /// Recursively builds an [_HtmlNode] tree. Children at each level are
  /// collected first, then sorted by heading priority before being stored.
  _HtmlNode _buildNode(Element element, int level) {
    final widget = element.widget;
    final children = _collectChildren(element, level);

    // Collect navLinks from children
    final List<SEONavItem> subtreeNavLinks = [];
    for (final child in children) {
      subtreeNavLinks.addAll(child.navLinks);
    }

    // Sort children by THEIR bubbled priority
    final sortedChildren = _sortedChildren(children);

    int ownPriority = 6;
    String openTag = '';
    String content = '';
    String closeTag = '';
    String tagName = '';
    String prependedTags = '';
    String appendedTags = '';
    String appendBeforeTag = '';
    String appendBeforeContent = '';
    String appendAfterContent = '';
    String appendAfterTag = '';

    if (widget is SEOWrapper) {
      final wrapper = widget as SEOWrapper;
      tagName = widget is BaseSEOWrapper ? widget.tagName : '';
      ownPriority = _headingPriority[tagName] ?? 6;

      if (widget is BaseSEOWrapper) {
        openTag = widget.getRawOpenTag();
        closeTag = widget.getRawCloseTag();
        appendBeforeTag = widget.appendBeforeTag;
        appendBeforeContent = widget.appendBeforeContent;
        appendAfterContent = widget.appendAfterContent;
        appendAfterTag = widget.appendAfterTag;
      } else {
        openTag = wrapper.getOpenTag();
        closeTag = wrapper.getCloseTag();
      }

      content = wrapper.getContent();

      // If it's a NavLink, add it to our list
      if (widget is SEONavLinkWrapper) {
        subtreeNavLinks.add(SEONavItem(text: widget.text ?? '', url: widget.path));
      }

      if (widget is BaseSEOWrapper && widget.additionalTags.isNotEmpty) {
        prependedTags =
            widget.additionalTags.where((t) => _headingPriority.containsKey(t.tag)).map((t) => t.toHtmlString()).join();
        appendedTags = widget.additionalTags
            .where((t) => !_headingPriority.containsKey(t.tag))
            .map((t) => t.toHtmlString())
            .join();

        // Update ownPriority if additionalTags contain higher priority headings
        for (final tag in widget.additionalTags) {
          final tagPriority = _headingPriority[tag.tag] ?? 6;
          if (tagPriority < ownPriority) {
            ownPriority = tagPriority;
          }
        }
      }

      // If it's a Nav, generate JSON-LD from collected links
      if (widget is SEONavWrapper && subtreeNavLinks.isNotEmpty) {
        final jsonLd = widget.isBreadcrumb
            ? SEOHtmlJsonLd.breadcrumbList(subtreeNavLinks)
            : SEOHtmlJsonLd.siteNavigation(subtreeNavLinks);
        appendedTags += jsonLd.toHtmlString();
      }
    }

    // Bubble up priority: take the minimum (highest importance)
    // of own priority and all children priorities.
    int bubbledPriority = ownPriority;
    for (final child in sortedChildren) {
      if (child.priority < bubbledPriority) {
        bubbledPriority = child.priority;
      }
    }

    return _HtmlNode(
      openTag: openTag,
      content: content,
      closeTag: closeTag,
      tagName: tagName,
      children: sortedChildren,
      priority: bubbledPriority,
      additionalPrependedTags: prependedTags,
      additionalAppendedTags: appendedTags,
      navLinks: subtreeNavLinks,
      appendBeforeTag: appendBeforeTag,
      appendBeforeContent: appendBeforeContent,
      appendAfterContent: appendAfterContent,
      appendAfterTag: appendAfterTag,
    );
  }

  List<_HtmlNode> _collectChildren(Element element, int level) {
    final nodes = <_HtmlNode>[];
    element.visitChildren((child) {
      nodes.add(_buildNode(child, level + 1));
    });
    return nodes;
  }

  /// Stable sort: heading tags (h1–h6) come first in priority order;
  /// all other siblings preserve their original relative order.
  static List<_HtmlNode> _sortedChildren(List<_HtmlNode> nodes) {
    final indexed = List.generate(
      nodes.length,
      (i) => (index: i, node: nodes[i]),
    );

    indexed.sort((a, b) {
      if (a.node.priority != b.node.priority) {
        return a.node.priority.compareTo(b.node.priority);
      }
      return a.index.compareTo(b.index);
    });

    return indexed.map((e) => e.node).toList();
  }

  void _serialize(_HtmlNode node, StringBuffer buffer) {
    if (node.appendBeforeTag.isNotEmpty) buffer.write(node.appendBeforeTag);

    if (node.openTag.isNotEmpty) {
      buffer.write(node.openTag);
      if (!node.openTag.endsWith('>')) {
        buffer.write('>');
      }
      if (node.openTag.endsWith('/')) {
        // It's a void tag, no content or children or close tag
        if (node.appendAfterTag.isNotEmpty) buffer.write(node.appendAfterTag);
        return;
      }
    }

    if (node.appendBeforeContent.isNotEmpty) buffer.write(node.appendBeforeContent);
    if (node.additionalPrependedTags.isNotEmpty) buffer.write(node.additionalPrependedTags);
    if (node.content.isNotEmpty) buffer.write(node.content);

    for (final child in node.children) {
      _serialize(child, buffer);
    }

    if (node.appendAfterContent.isNotEmpty) buffer.write(node.appendAfterContent);
    if (node.additionalAppendedTags.isNotEmpty) buffer.write(node.additionalAppendedTags);

    if (node.closeTag.isNotEmpty) buffer.write(node.closeTag);
    if (node.appendAfterTag.isNotEmpty) buffer.write(node.appendAfterTag);
  }
}

/// Intermediate representation of a single HTML element produced during
/// widget tree traversal. Children are already sorted by the time a node
/// is created.
class _HtmlNode {
  final String openTag;
  final String content;
  final String closeTag;
  final String tagName;
  final List<_HtmlNode> children;
  final int priority;
  final String additionalPrependedTags;
  final String additionalAppendedTags;
  final List<SEONavItem> navLinks;
  final String appendBeforeTag;
  final String appendBeforeContent;
  final String appendAfterContent;
  final String appendAfterTag;

  const _HtmlNode({
    required this.openTag,
    required this.content,
    required this.closeTag,
    required this.tagName,
    required this.children,
    required this.priority,
    this.additionalPrependedTags = '',
    this.additionalAppendedTags = '',
    this.navLinks = const [],
    this.appendBeforeTag = '',
    this.appendBeforeContent = '',
    this.appendAfterContent = '',
    this.appendAfterTag = '',
  });
}

/// Page metadata extracted from EasySEO widget
class SEOPageMetadata {
  final List<EasySEOHeadTag> headTags;

  SEOPageMetadata({this.headTags = const []});

  String generateMetadata() {
    final buffer = StringBuffer();
    for (var tag in headTags) {
      buffer.writeln(tag.toHtml());
    }
    return buffer.toString();
  }
}

/// Generates complete HTML document from widget tree content and metadata
class SEOHtmlDocumentGenerator {
  static String generateFullDocument({
    required String bodyContent,
    String? metadata,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
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
