part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

enum SEOTextType { h1, h2, h3, h4, h5, h6, p }

class EasySEOTextWrapper extends EasySEOBaseWrapper {
  const EasySEOTextWrapper({
    super.key,
    required super.child,
    this.textType = SEOTextType.p,
    super.className,
    super.attributes,
    super.globalName,
    super.children,
    super.jsonLd,
    this.text,
  });

  final SEOTextType textType;
  final String? text;

  @override
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  }) {
    final content = this.text ?? _extractTextFromChild(child);
    return _buildSimpleTag(tag: textType.name, content: content, children: children, context: context);
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
  State<StatefulWidget> createState() => _EasySEOTextWrapperState();
}

class _EasySEOTextWrapperState extends EasySEOBaseWrapperState<EasySEOTextWrapper> {}
