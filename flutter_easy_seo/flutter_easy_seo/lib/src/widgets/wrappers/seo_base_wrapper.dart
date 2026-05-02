part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

abstract class SEOWrapper {
  String getOpenTag();
  String getCloseTag();
  String getContent();
}

abstract class BaseSEOWrapper extends StatefulWidget implements SEOWrapper {
  const BaseSEOWrapper({super.key, required this.child, this.className, this.attributes, this.globalName});

  final Widget child;
  final String? className;
  final Map<String, String>? attributes;
  final String? globalName;

  static const _voidElements = {
    'img',
    'br',
    'hr',
    'meta',
    'link',
    'input',
    'source',
    'area',
    'base',
    'col',
    'embed',
    'param',
    'track',
    'wbr',
  };

  String get tagName;

  bool get _isVoid => BaseSEOWrapper._voidElements.contains(tagName);

  String get appendBeforeContent => "";

  String get appendAfterContent => "";

  String get appendBeforeTag => "";

  String get appendAfterTag => "";

  Map<String, String> get additionalAttributes => {};

  @override
  String getContent() => "";

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

abstract class BaseSEOWrapperState<T extends BaseSEOWrapper> extends State<T> {
  @override
  void initState() {
    super.initState();
    // Register the WIDGET instance, not the state
    if (widget.globalName != null) {
      EasySEOConfig.instance.globals[widget.globalName!] = context;
    }
  }

  @override
  void dispose() {
    // CLEANUP: Remove this widget from globals when it leaves the tree
    if (widget.globalName != null) {
      EasySEOConfig.instance.globals.remove(widget.globalName);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-register to ensure EasySEOConfig has the most recent 'widget' instance
    if (widget.globalName != null) {
      EasySEOConfig.instance.globals[widget.globalName!] = context;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
