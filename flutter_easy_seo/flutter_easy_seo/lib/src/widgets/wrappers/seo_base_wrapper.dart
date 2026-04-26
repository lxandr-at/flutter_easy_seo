part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

abstract class SEOWrapper {
  String getOpenTag();
  String getCloseTag();
}

abstract class SEOSelfClosingWrapper {
  String getTag();
}

abstract class BaseSEOWrapper extends StatelessWidget implements SEOWrapper {
  const BaseSEOWrapper({
    super.key,
    required Widget child,
    String? className,
    Map<String, String>? attributes,
  })  : _child = child,
        _className = className,
        _attributes = attributes;

  final Widget _child;
  final String? _className;
  final Map<String, String>? _attributes;

  Widget get child => _child;
  String? get className => _className;
  Map<String, String>? get attributes => _attributes;

  @override
  Widget build(BuildContext context) => _child;

  String get tagName;

  static const _voidElements = {'img', 'br', 'hr', 'meta', 'link', 'input', 'source', 'area', 'base', 'col', 'embed', 'param', 'track', 'wbr'};

  bool get _isVoid => _voidElements.contains(tagName);

  String get appendBeforeContent => "";
  String get appendAfterContent => "";
  String get appendBeforeTag => "";
  String get appendAfterTag => "";
  Map<String, String> get additionalAttributes => {};

  @override
  String getOpenTag({Map<String, String> overrideAttributes = const {}}) {
    final buffer = StringBuffer('$appendBeforeTag<$tagName');
    Map<String, String> allAttributes = {};
    if (className != null) {
      allAttributes["class"] = className!;
    }
    allAttributes.addAll(additionalAttributes);
    if (attributes != null) {
      allAttributes.addAll(attributes!);
    }
    // TODO maybe change to override only if not defined in attributes
    allAttributes.addAll(overrideAttributes);
    for (final entry in allAttributes.entries) {
      buffer.write(' ${entry.key}="${entry.value}"');
    }
    if (_isVoid) {
      buffer.write(' />');
    } else {
      buffer.write('>$appendBeforeContent');
    }
    return buffer.toString();
  }

  @override
  String getCloseTag() {
    if (_isVoid) return '';
    return '$appendAfterContent</$tagName>$appendAfterTag';
  }
}
