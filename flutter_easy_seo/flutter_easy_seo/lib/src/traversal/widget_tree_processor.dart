part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOWidgetTreeProcessor {
  StringBuffer _output = StringBuffer();
  SEOPageMetadata? _metadata;

  String processWidgetTree(Element rootElement) {
    _output = StringBuffer();
    _metadata = null;
    _traverseElement(rootElement);
    return _output.toString();
  }

  SEOPageMetadata? get metadata => _metadata;

  void _traverseElement(Element element) {
    final widget = element.widget;
    
    final handled = _dispatchToHandler(widget, element);
    if (!handled) {
      _traverseChildren(element);
    }
  }

  bool _dispatchToHandler(Widget widget, Element element) {
    final typeName = widget.runtimeType.toString();
    if (typeName == 'SEOTextWrapper') return _handleSEOTextWrapper(widget as SEOTextWrapper, element);
    if (typeName == 'SEOImageWrapper') return _handleSEOImageWrapper(widget as SEOImageWrapper, element);
    if (typeName == 'SEOSelfClosingWrapper') return _handleSEOSelfClosingWrapper(widget as SEOSelfClosingWrapper, element);
    if (_isSEOWrapper(typeName)) return _handleSEOWrapper(widget as SEOWrapper, element);
    return false;
  }

  bool _isSEOWrapper(String typeName) {
    const wrappers = [
      'SEOContainerWrapper', 'SEOListWrapper', 'SEONavigationWrapper',
      'SEOHeaderWrapper', 'SEOAsideWrapper', 'SEOMainWrapper',
      'SEOArticleWrapper', 'SEOSectionWrapper', 'SEOTimeWrapper',
      'SEOFigureWrapper', 'SEOFormWrapper', 'SEOCustomWrapper',
    ];
    return wrappers.contains(typeName);
  }

  bool _handleSEOTextWrapper(SEOTextWrapper wrapper, Element element) {
    final text = _extractTextFromChild(wrapper.child);
    _output.write(wrapper.onEnter());
    _output.write(text);
    _output.write(wrapper.onExit());
    return true;
  }

  bool _handleSEOImageWrapper(SEOImageWrapper wrapper, Element element) {
    final imgSrc = _extractImageSrcFromChild(wrapper.child);
    _output.write(wrapper.onEnter(resolvedSrc: imgSrc));
    return true;
  }

  bool _handleSEOSelfClosingWrapper(SEOSelfClosingWrapper wrapper, Element element) {
    _output.write(wrapper.onEnter());
    return true;
  }

  bool _handleSEOWrapper(SEOWrapper wrapper, Element element) {
    _output.write(wrapper.onEnter());
    _traverseChildren(element);
    _output.write(wrapper.onExit());
    return true;
  }

  void _traverseChildren(Element element) {
    element.visitChildren(_traverseElement);
  }

  String _extractTextFromChild(Widget child) {
    if (child is Text) return child.data ?? '';
    if (child is RichText) {
      final buffer = StringBuffer();
      final span = child.text;
      if (span is TextSpan) {
        _extractTextFromTextSpan(span, buffer);
      }
      return buffer.toString();
    }
    return '';
  }

  void _extractTextFromTextSpan(TextSpan span, StringBuffer buffer) {
    buffer.write(span.text ?? '');
    if (span.children != null) {
      for (final child in span.children!) {
        if (child is TextSpan) {
          _extractTextFromTextSpan(child, buffer);
        }
      }
    }
  }

  String? _extractImageSrcFromChild(Widget child) {
    if (child is Image) {
      final provider = child.image;
      if (provider is NetworkImage) {
        return provider.url;
      }
    }
    return null;
  }
}

/// Page metadata extracted from EasySEO widget
class SEOPageMetadata {
  final String? title;
  final String? description;
  final List<SEOTag>? headTags;
  final Map<String, String>? additionalTags;
  final String? canonicalUrl;

  SEOPageMetadata({
    this.title,
    this.description,
    this.headTags,
    this.additionalTags,
    this.canonicalUrl,
  });
}

/// Generates complete HTML document from widget tree content and metadata
class SEOHtmlDocumentGenerator {
  static String generateFullDocument({
    required String bodyContent,
    SEOPageMetadata? metadata,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    
    // Title
    if (metadata?.title != null) {
      buffer.writeln('  <title>${metadata!.title}</title>');
    } else {
      buffer.writeln('  <title></title>');
    }
    
    // Description
    if (metadata?.description != null) {
      buffer.writeln('  <meta name="description" content="${metadata!.description}">');
    }
    
    // Canonical URL
    if (metadata?.canonicalUrl != null) {
      buffer.writeln('  <link rel="canonical" href="${metadata!.canonicalUrl}">');
    }
    
    // Additional meta tags
    if (metadata?.additionalTags != null) {
      for (final entry in metadata!.additionalTags!.entries) {
        buffer.writeln('  <meta name="${entry.key}" content="${entry.value}">');
      }
    }
    
    // Custom head tags
    if (metadata?.headTags != null) {
      for (final tag in metadata!.headTags!) {
        final attrs = tag.attributes.entries.map((e) => '${e.key}="${e.value}"').join(' ');
        buffer.writeln('  <${tag.tagName} $attrs>');
      }
    }
    
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.write(bodyContent);
    buffer.writeln('</body>');
    buffer.writeln('</html>');
    
    return buffer.toString();
  }
}