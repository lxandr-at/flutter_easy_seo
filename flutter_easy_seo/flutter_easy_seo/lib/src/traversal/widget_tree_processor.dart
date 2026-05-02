part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOWidgetTreeProcessor {
  StringBuffer _output = StringBuffer();
  SEOPageMetadata? _metadata;

  String processWidgetTree(Element rootElement, List<String> includeGlobals) {
    _output = StringBuffer();
    _metadata = null;

    // add widget info from outside of
    for (var name in includeGlobals) {
      Element? element = EasySEOConfig.instance.globals[name] as Element?;
      if (element != null) {
        _traverseElement(element);
      }
    }

    _traverseElement(rootElement);
    return _output.toString();
  }

  SEOPageMetadata? get metadata => _metadata;

  void _traverseElement(Element element) {
    final widget = element.widget;
    final isWrapper = widget is SEOWrapper;

    if (isWrapper) {
      final wrapper = widget as SEOWrapper;
      _output.write(wrapper.getOpenTag());
      final content = wrapper.getContent();
      if (content.isNotEmpty) {
        _output.write(content);
      }
    }

    _traverseChildren(element);

    if (isWrapper) {
      _output.write((widget as SEOWrapper).getCloseTag());
    }
  }

  void _traverseChildren(Element element) {
    element.visitChildren(_traverseElement);
  }
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
