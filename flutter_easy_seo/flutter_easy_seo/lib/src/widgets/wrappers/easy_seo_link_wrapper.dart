part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOLinkWrapper extends EasySEOBaseWrapper {
  final String path;
  final String? text;

  const EasySEOLinkWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
    super.jsonLd,
    required this.path,
    this.text,
  });

  String get resolvedText => text ?? _extractTextFromChild(child);

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    return SEOAnchor(
      path: path,
      content: resolvedText,
      children: children,
    );
  }

  String _extractTextFromChild(Widget widgetChild) {
    if (widgetChild is Text) return widgetChild.data ?? '';
    if (widgetChild is RichText) {
      final buffer = StringBuffer();
      final span = widgetChild.text;
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

  @override
  State<StatefulWidget> createState() => _EasySEOLinkWrapperState();
}

class _EasySEOLinkWrapperState extends EasySEOBaseWrapperState<EasySEOLinkWrapper> {}
