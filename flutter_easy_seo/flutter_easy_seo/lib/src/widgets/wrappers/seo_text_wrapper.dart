part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

enum SEOTextType { h1, h2, h3, h4, h5, h6, p }

class SEOTextWrapper extends BaseSEOWrapper {
  const SEOTextWrapper(
      {super.key, required super.child, this.textType = SEOTextType.p, super.className, super.attributes, this.text});

  final SEOTextType textType;
  final String? text;

  @override
  String get tagName => textType.name;

  @override
  String getContent() => text ?? _extractTextFromChild(child);

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
  State<StatefulWidget> createState() => _SEOTextWrapperState();
}

class _SEOTextWrapperState extends BaseSEOWrapperState<SEOTextWrapper> {}
